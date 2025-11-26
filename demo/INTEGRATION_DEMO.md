# Notification Scheduler Integration Demo

This demo showcases the **proper integration pattern** for the Notification Scheduler plugin using the **autoload (singleton) pattern**, as recommended for production applications.

## 🎯 What This Demo Demonstrates

This enhanced demo shows how to integrate the Notification Scheduler plugin into a real application (simulated as "BingoTask" - a productivity app) with:

1. ✅ **NotificationManager Autoload** - Centralized notification management
2. ✅ **No Duplicate Nodes** - Single NotificationScheduler instance managed by autoload
3. ✅ **Proper Permission Flow** - User-friendly permission requests with status feedback
4. ✅ **Context-Aware Notifications** - Notifications triggered by app events
5. ✅ **Clean Architecture** - Separation of concerns between UI and notification logic

## 📁 Project Structure

```
demo/
├── main_menu.tscn/gd          # Entry point - shows notification status
├── bingo_board.tscn/gd        # Task management UI
├── board_manager.gd           # Business logic with notification triggers
├── NotificationManager.gd     # Autoload singleton (THE KEY PATTERN)
└── Main.tscn/gd              # Original plugin demo (kept for reference)
```

## 🔑 Key Integration Pattern: NotificationManager Autoload

### Why Use an Autoload?

Instead of adding `NotificationScheduler` nodes to every scene, we create a **single autoload** that:
- Initializes the plugin once
- Manages notification channels
- Handles permissions centrally
- Provides a clean API for the entire app

### Setup in project.godot

```ini
[autoload]
NotificationManager="*res://NotificationManager.gd"
```

### Using NotificationManager from Any Scene

```gdscript
# No need to instantiate - just use it!
NotificationManager.schedule_no_tasks_reminders()
NotificationManager.cancel_no_progress_reminder()
NotificationManager.request_notification_permission()
```

## 🔔 Notification Triggers in BingoTask Demo

The demo implements **smart notification triggers** based on user actions:

### 1. When First Task is Added
```gdscript
func add_task(task_name: String):
    if was_empty:
        # Cancel "add your first task" reminder
        NotificationManager.cancel_no_tasks_reminders()
        # Schedule "keep making progress" reminder
        NotificationManager.schedule_no_progress_reminder(1)
```

### 2. When Task is Completed
```gdscript
func complete_task(task_id: int):
    # Update progress reminder
    NotificationManager.cancel_no_progress_reminder()
    if remaining_tasks > 0:
        NotificationManager.schedule_no_progress_reminder(remaining_tasks)
```

### 3. When Board is Reset
```gdscript
func reset_board():
    # Encourage user to add tasks again
    NotificationManager.schedule_no_tasks_reminders()
```

### 4. When Scheduling Tasks for Future Date
```gdscript
func save_scheduled_tasks(date: String, task_list: Array):
    # Send morning & evening reminders
    NotificationManager.schedule_daily_task_reminder(date, task_list.size())
```

## 🎮 How to Use the Demo

### Main Menu
1. Launch the app - you'll see the **Main Menu**
2. Check notification permission status
3. Request permissions if needed (button appears if not granted)
4. Access app settings to manage notification preferences

### Bingo Board
1. Click **"📋 Open Bingo Board"** from main menu
2. **Add tasks** using the text input at the bottom
3. **Complete tasks** by clicking on them (they turn green)
4. **Reset board** to clear all tasks
5. **Schedule tasks** to trigger daily reminders

### Debug Keys (Editor Only)
- Press **`N`** - Schedule a test notification (5 seconds)
- Press **`M`** - Request notification permission

### Original Plugin Demo
Click **"🧪 Original Plugin Demo"** to see the basic plugin usage without the autoload pattern.

## 📱 Notification Types Implemented

| Notification ID | Type | Trigger | Delay |
|----------------|------|---------|-------|
| 1000 | No Tasks Reminder | Board is empty | 1 hour |
| 1001 | No Progress Reminder | Tasks incomplete for a while | 2 hours |
| 2000 | Daily Task Morning | Tasks scheduled for date | 10 min (demo) |
| 2001 | Daily Task Evening | Tasks scheduled for date | 20 min (demo) |

> **Note**: In a production app, you'd use real timestamps instead of fixed delays.

## 🏗️ Architecture Highlights

### Clean Separation of Concerns

```
┌─────────────────┐
│   UI Layer      │  bingo_board.gd
│  (User Input)   │  main_menu.gd
└────────┬────────┘
         │
┌────────▼────────┐
│ Business Logic  │  board_manager.gd
│  (Task Mgmt)    │  (calls NotificationManager)
└────────┬────────┘
         │
┌────────▼────────┐
│ NotificationMgr │  NotificationManager.gd (Autoload)
│   (Singleton)   │  (manages NotificationScheduler)
└────────┬────────┘
         │
┌────────▼────────┐
│ Plugin Layer    │  NotificationScheduler.gd
│  (Native APIs)  │  (Android/iOS native code)
└─────────────────┘
```

### Benefits of This Pattern

1. **Single Source of Truth** - One place manages all notifications
2. **No Duplicate Initialization** - Plugin initialized once
3. **Consistent Channel Management** - All notifications use same channel
4. **Easy Permission Handling** - Centralized permission state
5. **Testable** - Business logic separated from notification logic
6. **Maintainable** - Easy to update notification behavior

## 🔧 Customizing for Your App

### 1. Update Channel Configuration
Edit `NotificationManager.gd`:
```gdscript
const CHANNEL_ID: String = "your_app_channel"
const CHANNEL_NAME: String = "Your App Name"
const CHANNEL_DESCRIPTION: String = "Your description"
```

### 2. Define Your Notification IDs
```gdscript
enum NotificationId {
    YOUR_NOTIFICATION_1 = 1000,
    YOUR_NOTIFICATION_2 = 1001,
    # ... add more
}
```

### 3. Add Your Notification Methods
```gdscript
func schedule_your_notification(params) -> void:
    if not _is_ready():
        return
    
    var notification = NotificationData.new()\
        .set_id(NotificationId.YOUR_NOTIFICATION_1)\
        .set_channel_id(CHANNEL_ID)\
        .set_title("Your Title")\
        .set_content("Your content")\
        .set_delay(delay_seconds)
    
    notification_scheduler.schedule(notification)
```

### 4. Call from Your Business Logic
```gdscript
# In your scene/manager script
func on_some_event():
    NotificationManager.schedule_your_notification(params)
```

## ⚠️ Common Pitfalls to Avoid

### ❌ DON'T: Add NotificationScheduler to Multiple Scenes
```gdscript
# BAD - each scene creates its own instance
[node name="NotificationScheduler" type="Node" parent="."]
script = ExtResource("NotificationScheduler.gd")
```

### ✅ DO: Use the Autoload
```gdscript
# GOOD - use the singleton
NotificationManager.schedule_notification(...)
```

### ❌ DON'T: Initialize Multiple Times
```gdscript
# BAD
notification_scheduler.initialize()  # in scene A
notification_scheduler.initialize()  # in scene B
```

### ✅ DO: Initialize Once in Autoload
```gdscript
# GOOD - happens once in NotificationManager._ready()
notification_scheduler.initialize()
```

## 🚀 Production Checklist

Before shipping your app with notifications:

- [ ] Update channel ID, name, and description to match your app
- [ ] Define unique notification IDs for your app
- [ ] Use real timestamps instead of demo delays
- [ ] Add proper notification icons (Android)
- [ ] Test permission flow on real devices
- [ ] Test notification appearance on both Android & iOS
- [ ] Handle notification opened events appropriately
- [ ] Test with app in background/foreground
- [ ] Verify notifications respect system settings
- [ ] Add user preference to disable notifications (optional)

## 📚 Additional Resources

- [Plugin Documentation](../docs/README.md)
- [Original Plugin Demo](Main.tscn) - Basic usage without autoload
- [Plugin GitHub](https://github.com/godot-sdk-integrations/godot-notification-scheduler)

## 🤝 Contributing

This demo can be improved! Ideas:
- Add notification settings UI
- Implement notification history
- Add more trigger types
- Show notification preview
- Add scheduling calendar

See [CONTRIBUTING.md](../docs/CONTRIBUTING.md) for guidelines.

---

**© 2024-present** - Enhanced demo for the Godot Notification Scheduler Plugin
