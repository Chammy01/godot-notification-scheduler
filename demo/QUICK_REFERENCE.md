# Quick Reference: Notification Scheduler Integration

## 🎯 TL;DR - The Pattern

**1. Create NotificationManager autoload singleton**
**2. Register it in project.godot**
**3. Use it from anywhere: `NotificationManager.schedule_*()`**
**4. Never add NotificationScheduler nodes to scenes**

---

## Step-by-Step Integration

### Step 1: Create NotificationManager.gd

Create a singleton that manages the plugin:

```gdscript
extends Node

const CHANNEL_ID = "my_app_channel"
var notification_scheduler: NotificationScheduler = null
var permission_granted: bool = false

func _ready():
    notification_scheduler = NotificationScheduler.new()
    add_child(notification_scheduler)
    notification_scheduler.initialize()
    # Connect signals...
```

### Step 2: Register as Autoload

In `project.godot`:

```ini
[autoload]
NotificationManager="*res://NotificationManager.gd"
```

### Step 3: Use from Anywhere

```gdscript
# In any script
NotificationManager.schedule_custom_notification(
    1, "Title", "Content", 60
)
```

---

## Common Patterns

### Request Permission
```gdscript
if not NotificationManager.permission_granted:
    NotificationManager.request_notification_permission()
```

### Schedule Notification
```gdscript
NotificationManager.schedule_custom_notification(
    id: int,
    title: String,
    content: String,
    delay_seconds: int
)
```

### Cancel Notification
```gdscript
NotificationManager.cancel_notification(id: int)
```

### Open Settings
```gdscript
NotificationManager.open_notification_settings()
```

---

## Event-Based Triggers

### User Creates First Item
```gdscript
if items.is_empty():
    NotificationManager.schedule_welcome_reminder()
```

### User Completes Action
```gdscript
NotificationManager.cancel_inactivity_reminder()
if more_work_to_do:
    NotificationManager.schedule_progress_reminder()
```

### User Schedules Future Event
```gdscript
NotificationManager.schedule_event_reminder(
    event_date, event_name
)
```

---

## File Structure

```
your_project/
├── project.godot              # Register autoload here
├── NotificationManager.gd     # Singleton (see demo)
├── scenes/
│   ├── main_menu.tscn        # NO NotificationScheduler node
│   ├── gameplay.tscn         # NO NotificationScheduler node
│   └── settings.tscn         # NO NotificationScheduler node
└── scripts/
    ├── game_manager.gd       # Calls NotificationManager
    ├── task_manager.gd       # Calls NotificationManager
    └── scheduler.gd          # Calls NotificationManager
```

---

## What NOT to Do

### ❌ Adding NotificationScheduler to Scenes
```gdscript
# DON'T do this in your .tscn files:
[node name="NotificationScheduler" type="Node" parent="."]
script = ExtResource("NotificationScheduler.gd")
```

### ❌ Initializing Multiple Times
```gdscript
# DON'T call initialize() in multiple places
notification_scheduler.initialize()  # Should only happen once!
```

### ❌ Creating Multiple Instances
```gdscript
# DON'T do this:
var my_scheduler = NotificationScheduler.new()  # Bad!
```

---

## Notification ID Management

### Define as Constants
```gdscript
# In NotificationManager.gd
enum NotificationId {
    WELCOME = 1000,
    DAILY_REMINDER = 2000,
    PROGRESS = 3000,
    ACHIEVEMENT = 4000,
}
```

### Use in Methods
```gdscript
func schedule_welcome():
    schedule_custom_notification(
        NotificationId.WELCOME,
        "Welcome!",
        "Start your journey",
        60
    )
```

---

## Permission Flow

### Check Status
```gdscript
if NotificationManager.permission_granted:
    # Ready to schedule
else:
    # Need to request
```

### Request Permission
```gdscript
NotificationManager.request_notification_permission()
# User sees system dialog
# Results come via signals connected in NotificationManager
```

### Handle Denial
```gdscript
# In NotificationManager._on_permission_denied:
func _on_permission_denied(permission_name: String):
    permission_granted = false
    # Show user message explaining they can enable in settings
```

---

## Testing Notifications

### Add Debug Commands
```gdscript
func _input(event):
    if OS.is_debug_build() and event is InputEventKey:
        if event.keycode == KEY_N and event.pressed:
            NotificationManager.schedule_custom_notification(
                9999, "Test", "Debug notification", 5
            )
```

### Check Logs
```gdscript
# NotificationManager logs everything:
# 📱 NotificationManager: Scheduling...
# ✅ NotificationManager: Scheduled successfully
# 🚫 NotificationManager: Canceled...
```

### Use adb logcat (Android)
```bash
adb logcat | grep "godot"
```

---

## See Full Demo

For complete working example, see the demo files:
- `demo/NotificationManager.gd` - Full implementation
- `demo/board_manager.gd` - Usage example
- `demo/INTEGRATION_DEMO.md` - Detailed documentation

---

**Quick Start**: Copy `demo/NotificationManager.gd` to your project, register it as autoload, and start calling its methods!
