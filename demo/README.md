# Notification Scheduler Demo

Welcome to the enhanced notification scheduler demo! This demo showcases **production-ready integration patterns** for the Godot Notification Scheduler plugin.

## 🎯 What's Included

### Two Demo Modes

1. **Enhanced Integration Demo** (⭐ Recommended for production apps)
   - Entry Point: `main_menu.tscn`
   - Shows proper autoload (singleton) pattern
   - Context-aware notifications
   - Clean architecture with separation of concerns
   
2. **Basic Plugin Demo** (📚 Learning reference)
   - Entry Point: `Main.tscn` 
   - Direct plugin usage for learning
   - All plugin features demonstrated

## 🚀 Quick Start

### Running the Demo

1. Open the project in Godot 4.x
2. Run the project (F5)
3. Main menu will show notification status
4. Click **"📋 Open Bingo Board"** to see the integration in action

### What to Try

**In the Bingo Board:**
- ➕ Add tasks and see notifications get scheduled
- ✅ Complete tasks and watch reminders update
- 🔄 Reset the board to trigger new reminders
- 📅 Use "Schedule Tasks" to set daily reminders

**Debug Commands (Editor/Debug builds only):**
- Press `N` - Schedule test notification (5 seconds)
- Press `M` - Request notification permission

## 📁 File Guide

### Core Integration Files
- **NotificationManager.gd** - ⭐ The centerpiece! Copy this to your project
- **project.godot** - See autoload registration example

### Demo Scenes
- **main_menu.tscn/gd** - Shows how to check notification status
- **bingo_board.tscn/gd** - Shows UI integration
- **board_manager.gd** - Shows business logic with notification triggers

### Documentation
- **[INTEGRATION_DEMO.md](INTEGRATION_DEMO.md)** - 📖 Full integration guide
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - ⚡ Quick-start guide
- **[SECURITY_ANALYSIS.md](SECURITY_ANALYSIS.md)** - 🔒 Security review

### Original Demo
- **Main.tscn/gd** - Basic plugin usage (kept for reference)

## 🎓 Learning Path

### New to the Plugin?
1. Read the [main README](../docs/README.md) for plugin basics
2. Run `Main.tscn` to see direct plugin usage
3. Study `NotificationManager.gd` to understand the autoload pattern
4. Read [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for integration tips

### Ready to Integrate?
1. Copy `NotificationManager.gd` to your project
2. Register it as autoload in your `project.godot`
3. Follow patterns in `board_manager.gd` for your business logic
4. Reference [INTEGRATION_DEMO.md](INTEGRATION_DEMO.md) for details

## 🏗️ Architecture Pattern

```
Your App Structure:

NotificationManager (Autoload Singleton)
    ↓ manages
NotificationScheduler (Plugin)
    ↓ wraps
Native Android/iOS APIs

Your Scenes → NotificationManager → Plugin → Platform
(No direct plugin nodes in scenes!)
```

## ✨ Key Concepts Demonstrated

### 1. Autoload Pattern
```gdscript
# In any script, anywhere:
NotificationManager.schedule_notification(...)
```
**Why?** Single initialization, consistent behavior, clean code.

### 2. Permission Flow
```gdscript
# Check status
if NotificationManager.permission_granted:
    # Schedule notifications
else:
    # Show UI to request permission
    NotificationManager.request_notification_permission()
```
**Why?** Explicit user consent, better UX, privacy compliance.

### 3. Event-Driven Notifications
```gdscript
# When user completes an action:
func on_task_completed():
    # Update notifications based on state
    NotificationManager.cancel_old_reminder()
    NotificationManager.schedule_new_reminder()
```
**Why?** Relevant notifications, not spammy, context-aware.

## 🛠️ Customization Guide

### For Your App

1. **Update Channel Info** in `NotificationManager.gd`:
```gdscript
const CHANNEL_ID = "your_app_channel"
const CHANNEL_NAME = "Your App Name"
```

2. **Define Your Notification IDs**:
```gdscript
enum NotificationId {
    YOUR_NOTIFICATION_1 = 1000,
    YOUR_NOTIFICATION_2 = 2000,
}
```

3. **Add Your Methods**:
```gdscript
func schedule_your_notification():
    # Copy pattern from existing methods
```

4. **Call from Your Code**:
```gdscript
NotificationManager.schedule_your_notification()
```

## 📱 Platform Notes

### Android
- Notification icons: Place in `assets/NotificationSchedulerPlugin/`
- Permissions: Requested at runtime (Android 13+)
- Testing: Use `adb logcat | grep godot`

### iOS
- Notification icons: Set in Export settings
- Limits: Max 64 repeating notifications, min 60s interval
- Testing: View XCode logs

## 🔍 Troubleshooting

### Notifications not appearing?
1. Check permission status in main menu
2. Look for errors in output console
3. Verify notification channel created
4. Check system notification settings

### Permission request not showing?
1. Make sure you're on Android 13+ or iOS
2. Check if already granted/denied in settings
3. See logs for permission state

### App crashes on launch?
1. Verify addon is enabled in Project Settings
2. Check that NotificationManager.gd has no syntax errors
3. Ensure plugin files are in correct location

## 📚 Additional Resources

- [Plugin Documentation](../docs/README.md)
- [GitHub Issues](https://github.com/godot-sdk-integrations/godot-notification-scheduler/issues)
- [Godot Mobile Export Guide](https://docs.godotengine.org/en/stable/tutorials/export/)

## 🤝 Contributing

Found ways to improve the demo? Contributions welcome!

See [CONTRIBUTING.md](../docs/CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License - Same as the main plugin

---

## 💡 Pro Tips

1. **Start Simple**: Copy `NotificationManager.gd` and register it as autoload. That's 90% of the work!

2. **Test Early**: Use the debug commands (N/M keys) to test without waiting for real delays.

3. **Think Events**: Trigger notifications when something happens, not on timers.

4. **Unique IDs**: Use enums for notification IDs to avoid conflicts.

5. **User First**: Always explain why you need permissions before requesting.

---

**Questions?** Check the [INTEGRATION_DEMO.md](INTEGRATION_DEMO.md) for detailed explanations!

**Need Quick Answer?** See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for common patterns!

**Security Concerns?** Review [SECURITY_ANALYSIS.md](SECURITY_ANALYSIS.md) for assurance!

---

Happy coding! 🚀

**© 2024-present** - Enhanced by the Godot community
