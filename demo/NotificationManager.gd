#
# © 2024-present https://github.com/cengiz-pz
#
# NotificationManager - Autoload singleton for managing notifications
# Provides a centralized interface for scheduling and managing notifications
# throughout the application lifecycle
#

extends Node

## Notification channel configuration
const CHANNEL_ID: String = "bingo_task_channel"
const CHANNEL_NAME: String = "BingoTask Notifications"
const CHANNEL_DESCRIPTION: String = "Notifications for task reminders and progress updates"

## Notification IDs - must be unique across the app
enum NotificationId {
	NO_TASKS_REMINDER = 1000,
	NO_PROGRESS_REMINDER = 1001,
	DAILY_TASK_MORNING = 2000,
	DAILY_TASK_EVENING = 2001,
}

## Permission state
var permission_granted: bool = false
var initialization_completed: bool = false

## NotificationScheduler reference
var notification_scheduler: NotificationScheduler = null


func _ready() -> void:
	print("📱 NotificationManager: Initializing...")
	_initialize_scheduler()


func _initialize_scheduler() -> void:
	# Create a NotificationScheduler instance
	notification_scheduler = NotificationScheduler.new()
	add_child(notification_scheduler)
	
	# Connect signals
	notification_scheduler.initialization_completed.connect(_on_plugin_ready)
	notification_scheduler.permission_granted.connect(_on_permission_granted)
	notification_scheduler.permission_denied.connect(_on_permission_denied)
	notification_scheduler.notification_opened.connect(_on_notification_opened)
	notification_scheduler.notification_dismissed.connect(_on_notification_dismissed)
	
	# Initialize the plugin
	notification_scheduler.initialize()


func _on_plugin_ready() -> void:
	initialization_completed = true
	print("✅ NotificationManager: Plugin initialized")
	
	# Check permission status
	if notification_scheduler.has_post_notifications_permission():
		permission_granted = true
		_create_notification_channel()
	else:
		print("⚠️ NotificationManager: Notification permission not granted")
		# Note: Permission should be requested by user action, not automatically
		# The app should show UI to explain why permissions are needed


func _create_notification_channel() -> void:
	print("📢 NotificationManager: Creating notification channel...")
	
	var channel = NotificationChannel.new()\
			.set_id(CHANNEL_ID)\
			.set_name(CHANNEL_NAME)\
			.set_description(CHANNEL_DESCRIPTION)\
			.set_importance(NotificationChannel.Importance.DEFAULT)
	
	var result = notification_scheduler.create_notification_channel(channel)
	
	if result == OK:
		print("✅ NotificationManager: Notification channel created successfully")
	elif result == ERR_ALREADY_EXISTS:
		print("ℹ️ NotificationManager: Notification channel already exists")
	else:
		push_error("❌ NotificationManager: Failed to create notification channel: " + str(result))


func request_notification_permission() -> void:
	if not notification_scheduler:
		push_error("❌ NotificationManager: Cannot request permission - scheduler not initialized")
		return
	
	print("🔔 NotificationManager: Requesting notification permission...")
	notification_scheduler.request_post_notifications_permission()


func _on_permission_granted(permission_name: String) -> void:
	permission_granted = true
	print("✅ NotificationManager: Permission granted: " + permission_name)
	_create_notification_channel()


func _on_permission_denied(permission_name: String) -> void:
	permission_granted = false
	push_error("❌ NotificationManager: Permission denied: " + permission_name)
	print("💡 NotificationManager: User can enable notifications in app settings")


func _on_notification_opened(notification_data: NotificationData) -> void:
	print("📱 NotificationManager: Notification opened - ID: %d" % notification_data.get_id())
	# Clear badge count when notification is opened
	if notification_scheduler:
		notification_scheduler.set_badge_count(0)


func _on_notification_dismissed(notification_data: NotificationData) -> void:
	print("🗑️ NotificationManager: Notification dismissed - ID: %d" % notification_data.get_id())


## Schedule a reminder for when no tasks have been added
func schedule_no_tasks_reminders() -> void:
	if not _is_ready():
		return
	
	print("⏰ NotificationManager: Scheduling 'no tasks' reminder")
	
	var notification = NotificationData.new()\
			.set_id(NotificationId.NO_TASKS_REMINDER)\
			.set_channel_id(CHANNEL_ID)\
			.set_title("Start Your Bingo Board! 🎯")\
			.set_content("Add your first task to get started with your productivity goals!")\
			.set_small_icon_name(NotificationScheduler.DEFAULT_ICON_NAME)\
			.set_delay(3600)  # 1 hour from now
	
	var result = notification_scheduler.schedule(notification)
	if result == OK:
		print("✅ NotificationManager: 'No tasks' reminder scheduled")
	else:
		push_error("❌ NotificationManager: Failed to schedule 'no tasks' reminder: " + str(result))


## Cancel the 'no tasks' reminder
func cancel_no_tasks_reminders() -> void:
	if not _is_ready():
		return
	
	print("🚫 NotificationManager: Canceling 'no tasks' reminder")
	notification_scheduler.cancel(NotificationId.NO_TASKS_REMINDER)


## Schedule a reminder for when no progress has been made
func schedule_no_progress_reminder(remaining_tasks: int) -> void:
	if not _is_ready():
		return
	
	print("⏰ NotificationManager: Scheduling 'no progress' reminder for %d tasks" % remaining_tasks)
	
	var notification = NotificationData.new()\
			.set_id(NotificationId.NO_PROGRESS_REMINDER)\
			.set_channel_id(CHANNEL_ID)\
			.set_title("Keep Going! 💪")\
			.set_content("You have %d tasks remaining. Complete one now!" % remaining_tasks)\
			.set_small_icon_name(NotificationScheduler.DEFAULT_ICON_NAME)\
			.set_delay(7200)  # 2 hours from now
	
	var result = notification_scheduler.schedule(notification)
	if result == OK:
		print("✅ NotificationManager: 'No progress' reminder scheduled")
	else:
		push_error("❌ NotificationManager: Failed to schedule 'no progress' reminder: " + str(result))


## Cancel the 'no progress' reminder
func cancel_no_progress_reminder() -> void:
	if not _is_ready():
		return
	
	print("🚫 NotificationManager: Canceling 'no progress' reminder")
	notification_scheduler.cancel(NotificationId.NO_PROGRESS_REMINDER)


## Schedule daily task reminder
func schedule_daily_task_reminder(date: String, task_count: int) -> void:
	if not _is_ready():
		return
	
	print("⏰ NotificationManager: Scheduling daily reminder for %s with %d tasks" % [date, task_count])
	
	# Morning reminder (6 AM)
	var morning_notification = NotificationData.new()\
			.set_id(NotificationId.DAILY_TASK_MORNING)\
			.set_channel_id(CHANNEL_ID)\
			.set_title("Good Morning! ☀️")\
			.set_content("You have %d tasks scheduled for today. Let's get started!" % task_count)\
			.set_small_icon_name(NotificationScheduler.DEFAULT_ICON_NAME)\
			.set_delay(600)  # 10 minutes for demo purposes
	
	var result_morning = notification_scheduler.schedule(morning_notification)
	if result_morning == OK:
		print("✅ NotificationManager: Morning reminder scheduled")
	else:
		push_error("❌ NotificationManager: Failed to schedule morning reminder: " + str(result_morning))
	
	# Evening reminder (6 PM)
	var evening_notification = NotificationData.new()\
			.set_id(NotificationId.DAILY_TASK_EVENING)\
			.set_channel_id(CHANNEL_ID)\
			.set_title("Evening Check-In 🌙")\
			.set_content("Review your progress! %d tasks were planned for today." % task_count)\
			.set_small_icon_name(NotificationScheduler.DEFAULT_ICON_NAME)\
			.set_delay(1200)  # 20 minutes for demo purposes
	
	var result_evening = notification_scheduler.schedule(evening_notification)
	if result_evening == OK:
		print("✅ NotificationManager: Evening reminder scheduled")
	else:
		push_error("❌ NotificationManager: Failed to schedule evening reminder: " + str(result_evening))


## Cancel daily task reminders
func cancel_daily_task_reminders() -> void:
	if not _is_ready():
		return
	
	print("🚫 NotificationManager: Canceling daily task reminders")
	notification_scheduler.cancel(NotificationId.DAILY_TASK_MORNING)
	notification_scheduler.cancel(NotificationId.DAILY_TASK_EVENING)


## Open app notification settings
func open_notification_settings() -> void:
	if not _is_ready():
		return
	
	print("⚙️ NotificationManager: Opening app notification settings")
	notification_scheduler.open_app_info_settings()


## Check if the manager is ready to schedule notifications
func _is_ready() -> bool:
	if not initialization_completed:
		push_error("❌ NotificationManager: Plugin not yet initialized")
		return false
	
	if not permission_granted:
		push_error("❌ NotificationManager: Notification permission not granted")
		return false
	
	if not notification_scheduler:
		push_error("❌ NotificationManager: Scheduler not available")
		return false
	
	return true


## Helper method to schedule a custom notification
func schedule_custom_notification(id: int, title: String, content: String, delay_seconds: int) -> void:
	if not _is_ready():
		return
	
	print("⏰ NotificationManager: Scheduling custom notification (ID: %d)" % id)
	
	var notification = NotificationData.new()\
			.set_id(id)\
			.set_channel_id(CHANNEL_ID)\
			.set_title(title)\
			.set_content(content)\
			.set_small_icon_name(NotificationScheduler.DEFAULT_ICON_NAME)\
			.set_delay(delay_seconds)
	
	var result = notification_scheduler.schedule(notification)
	if result == OK:
		print("✅ NotificationManager: Custom notification scheduled")
	else:
		push_error("❌ NotificationManager: Failed to schedule custom notification: " + str(result))


## Helper method to cancel a custom notification
func cancel_notification(id: int) -> void:
	if not _is_ready():
		return
	
	print("🚫 NotificationManager: Canceling notification (ID: %d)" % id)
	notification_scheduler.cancel(id)
