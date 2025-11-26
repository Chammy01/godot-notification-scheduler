# Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Interface                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │  main_menu   │  │ bingo_board  │  │    Main      │         │
│  │  (Entry UI)  │  │  (Task UI)   │  │ (Basic Demo) │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
└─────────┼──────────────────┼──────────────────┼────────────────┘
          │                  │                  │
          │ Uses             │ Uses             │ Uses directly
          ▼                  ▼                  ▼
┌─────────────────────────────────────┐  ┌─────────────────┐
│    NotificationManager (Autoload)   │  │ NotificationSch │
│  ┌─────────────────────────────┐   │  │   (Direct)      │
│  │ • Initialize plugin          │   │  └────────┬────────┘
│  │ • Manage permissions         │   │           │
│  │ • Create channels            │   │           │
│  │ • Schedule notifications     │◄──┼───────────┘
│  │ • Cancel notifications       │   │   (Uses singleton)
│  │ • Track state                │   │
│  └──────────────┬──────────────┘   │
└─────────────────┼────────────────────┘
                  │ Wraps
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│              NotificationScheduler (Plugin)                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │ • GDScript wrapper for native code                        │  │
│  │ • Handles cross-platform differences                      │  │
│  │ • Emits signals for events                                │  │
│  │ • Provides unified API                                    │  │
│  └────────────────────────┬─────────────────────────────────┘  │
└───────────────────────────┼────────────────────────────────────┘
                            │ Calls
                ┌───────────┴───────────┐
                ▼                       ▼
    ┌─────────────────────┐ ┌─────────────────────┐
    │   Android Native    │ │    iOS Native       │
    │                     │ │                     │
    │ • AlarmManager      │ │ • UserNotifications │
    │ • NotificationMgr   │ │   Framework         │
    │ • JobScheduler      │ │ • UNUserNotif...    │
    └─────────────────────┘ └─────────────────────┘
```

## Data Flow

### 1. Initialization Flow

```
App Start
    │
    ▼
NotificationManager._ready()
    │
    ├─► Create NotificationScheduler instance
    │
    ├─► Connect signals
    │
    ├─► Call initialize()
    │
    ▼
NotificationScheduler.initialize()
    │
    ├─► Get native singleton
    │
    ├─► Connect native signals
    │
    └─► Call native initialize()
         │
         ▼
    Native Plugin Initializes
         │
         └─► Emits initialization_completed signal
              │
              ▼
    NotificationManager._on_plugin_ready()
         │
         ├─► Check permissions
         │
         └─► Create notification channel
```

### 2. Permission Request Flow

```
User Clicks "Request Permission" Button
    │
    ▼
main_menu._on_permissions_pressed()
    │
    ▼
NotificationManager.request_notification_permission()
    │
    ▼
NotificationScheduler.request_post_notifications_permission()
    │
    ▼
Native Permission Dialog
    │
    ├─► User Grants ──────► permission_granted signal
    │                           │
    │                           ▼
    │                  NotificationManager._on_permission_granted()
    │                           │
    │                           ├─► Set permission_granted = true
    │                           │
    │                           └─► Create notification channel
    │
    └─► User Denies ──────► permission_denied signal
                                │
                                ▼
                       NotificationManager._on_permission_denied()
                                │
                                └─► Set permission_granted = false
```

### 3. Notification Scheduling Flow

```
User Action (e.g., adds task)
    │
    ▼
bingo_board._on_add_task_pressed()
    │
    ▼
board_manager.add_task(task_name)
    │
    ├─► Update internal state
    │
    └─► NotificationManager.cancel_no_tasks_reminders()
         │
         └─► NotificationManager.schedule_no_progress_reminder(1)
              │
              ▼
         NotificationManager.schedule_custom_notification()
              │
              ├─► Check if ready (_is_ready())
              │    ├─► initialization_completed?
              │    ├─► permission_granted?
              │    └─► scheduler available?
              │
              ├─► Create NotificationData
              │
              └─► NotificationScheduler.schedule(data)
                   │
                   ▼
              Native Scheduling
                   │
                   └─► (After delay) System shows notification
```

### 4. Notification Opened Flow

```
User Taps Notification
    │
    ▼
Native System Event
    │
    ▼
NotificationScheduler receives event
    │
    └─► Emits notification_opened signal with NotificationData
         │
         ▼
    NotificationManager._on_notification_opened(data)
         │
         ├─► Clear badge count
         │
         └─► Log notification ID
              │
              ▼
    board_manager._on_notification_opened(data)
         │
         └─► Handle app-specific logic
              (e.g., navigate to specific screen)
```

## Class Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                     NotificationManager                      │
│  (Autoload Singleton - Always available)                    │
├─────────────────────────────────────────────────────────────┤
│ Properties:                                                  │
│  • notification_scheduler: NotificationScheduler            │
│  • permission_granted: bool                                 │
│  • initialization_completed: bool                           │
├─────────────────────────────────────────────────────────────┤
│ Methods:                                                     │
│  • schedule_no_tasks_reminders()                            │
│  • cancel_no_tasks_reminders()                              │
│  • schedule_no_progress_reminder(count)                     │
│  • cancel_no_progress_reminder()                            │
│  • schedule_daily_task_reminder(date, count)                │
│  • schedule_custom_notification(...)                        │
│  • request_notification_permission()                        │
│  • open_notification_settings()                             │
└───────────────────────┬─────────────────────────────────────┘
                        │ Contains 1
                        ▼
┌─────────────────────────────────────────────────────────────┐
│                  NotificationScheduler                       │
│  (Plugin wrapper - Created by NotificationManager)          │
├─────────────────────────────────────────────────────────────┤
│ Signals:                                                     │
│  • initialization_completed()                               │
│  • notification_opened(NotificationData)                    │
│  • notification_dismissed(NotificationData)                 │
│  • permission_granted(String)                               │
│  • permission_denied(String)                                │
├─────────────────────────────────────────────────────────────┤
│ Methods:                                                     │
│  • initialize()                                             │
│  • schedule(NotificationData)                               │
│  • cancel(id)                                               │
│  • create_notification_channel(NotificationChannel)         │
│  • has_post_notifications_permission()                      │
│  • request_post_notifications_permission()                  │
│  • open_app_info_settings()                                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      board_manager                           │
│  (Business Logic - Calls NotificationManager)               │
├─────────────────────────────────────────────────────────────┤
│ Signals:                                                     │
│  • task_added(String)                                       │
│  • task_completed(String)                                   │
│  • board_reset()                                            │
├─────────────────────────────────────────────────────────────┤
│ Methods:                                                     │
│  • add_task(name) → calls NotificationManager              │
│  • complete_task(id) → calls NotificationManager           │
│  • reset_board() → calls NotificationManager               │
│  • save_scheduled_tasks() → calls NotificationManager      │
└─────────────────────────────────────────────────────────────┘
```

## Why This Architecture?

### 🎯 Single Responsibility
- **NotificationManager**: Only manages notifications
- **board_manager**: Only manages tasks
- **UI scripts**: Only handle user interaction

### 🔄 Loose Coupling
- UI doesn't know about NotificationScheduler plugin
- Business logic doesn't know about native APIs
- Easy to mock for testing

### 📦 Encapsulation
- Plugin complexity hidden behind NotificationManager
- Permission state managed in one place
- Notification IDs managed centrally

### 🚀 Scalability
- Easy to add new notification types
- Simple to change notification behavior
- No duplicate code across scenes

### 🛠️ Maintainability
- Clear separation of concerns
- Easy to debug (logs at each layer)
- Simple to update or replace components

---

This architecture is **production-ready** and follows Godot best practices!
