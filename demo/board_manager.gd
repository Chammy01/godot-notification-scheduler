#
# © 2024-present https://github.com/cengiz-pz
#
# BoardManager - Manages the bingo board state and notification triggers
# Demonstrates proper integration with NotificationManager autoload
#

extends Node

signal task_added(task_name: String)
signal task_completed(task_name: String)
signal board_reset()

## Board state
var tasks: Array[Dictionary] = []
var completed_tasks: Array[String] = []
var max_tasks: int = 9  # 3x3 bingo board

## For testing scheduled tasks
var scheduled_tasks: Dictionary = {}  # date -> [tasks]


func _ready() -> void:
	print("🎮 BoardManager: Ready")
	
	# Connect to NotificationManager signals if needed
	if NotificationManager:
		NotificationManager.notification_scheduler.notification_opened.connect(_on_notification_opened)


## Add a task to the board
func add_task(task_name: String) -> bool:
	if tasks.size() >= max_tasks:
		print("⚠️ BoardManager: Board is full!")
		return false
	
	var was_empty = tasks.is_empty()
	
	var task = {
		"name": task_name,
		"completed": false,
		"id": tasks.size()
	}
	tasks.append(task)
	task_added.emit(task_name)
	
	print("✅ BoardManager: Task added - '%s' (Total: %d)" % [task_name, tasks.size()])
	
	# Notification trigger: first task added
	if was_empty:
		print("📱 BoardManager: First task added - canceling 'no tasks' reminders")
		NotificationManager.cancel_no_tasks_reminders()
		# Schedule a progress reminder
		NotificationManager.schedule_no_progress_reminder(tasks.size())
	
	return true


## Complete a task
func complete_task(task_id: int) -> bool:
	if task_id < 0 or task_id >= tasks.size():
		print("⚠️ BoardManager: Invalid task ID: %d" % task_id)
		return false
	
	var task = tasks[task_id]
	if task.completed:
		print("ℹ️ BoardManager: Task already completed: '%s'" % task.name)
		return false
	
	task.completed = true
	completed_tasks.append(task.name)
	task_completed.emit(task.name)
	
	var remaining = _count_remaining_tasks()
	print("✅ BoardManager: Task completed - '%s' (Remaining: %d)" % [task.name, remaining])
	
	# Notification trigger: task completed
	print("📱 BoardManager: Task completed - updating progress reminders")
	NotificationManager.cancel_no_progress_reminder()
	
	if remaining > 0:
		# Schedule new reminder for remaining tasks
		NotificationManager.schedule_no_progress_reminder(remaining)
	else:
		print("🎉 BoardManager: All tasks completed!")
	
	return true


## Reset the board
func reset_board() -> void:
	print("🔄 BoardManager: Resetting board")
	
	tasks.clear()
	completed_tasks.clear()
	board_reset.emit()
	
	# Notification trigger: board reset
	print("📱 BoardManager: Board reset - scheduling 'no tasks' reminders")
	NotificationManager.cancel_no_progress_reminder()
	NotificationManager.schedule_no_tasks_reminders()


## Save scheduled tasks for a specific date
func save_scheduled_tasks(date: String, task_list: Array) -> void:
	scheduled_tasks[date] = task_list
	print("📅 BoardManager: Saved %d tasks for %s" % [task_list.size(), date])
	
	# Notification trigger: scheduled tasks saved
	if task_list.size() > 0:
		print("📱 BoardManager: Scheduling daily task reminder for %s" % date)
		NotificationManager.schedule_daily_task_reminder(date, task_list.size())


## Remove a task
func remove_task(task_id: int) -> bool:
	if task_id < 0 or task_id >= tasks.size():
		print("⚠️ BoardManager: Invalid task ID: %d" % task_id)
		return false
	
	var task = tasks[task_id]
	tasks.remove_at(task_id)
	print("🗑️ BoardManager: Task removed - '%s'" % task.name)
	
	# Update IDs
	for i in range(tasks.size()):
		tasks[i].id = i
	
	# Notification trigger: check if board is now empty
	if tasks.is_empty():
		print("📱 BoardManager: Board now empty - scheduling 'no tasks' reminders")
		NotificationManager.cancel_no_progress_reminder()
		NotificationManager.schedule_no_tasks_reminders()
	else:
		var remaining = _count_remaining_tasks()
		if remaining > 0:
			NotificationManager.cancel_no_progress_reminder()
			NotificationManager.schedule_no_progress_reminder(remaining)
	
	return true


## Get task by ID
func get_task(task_id: int) -> Dictionary:
	if task_id >= 0 and task_id < tasks.size():
		return tasks[task_id]
	return {}


## Get all tasks
func get_all_tasks() -> Array[Dictionary]:
	return tasks


## Count remaining (incomplete) tasks
func _count_remaining_tasks() -> int:
	var count = 0
	for task in tasks:
		if not task.completed:
			count += 1
	return count


## Get completion percentage
func get_completion_percentage() -> float:
	if tasks.is_empty():
		return 0.0
	return (completed_tasks.size() / float(tasks.size())) * 100.0


## Handle notification opened
func _on_notification_opened(notification_data: NotificationData) -> void:
	print("📱 BoardManager: App opened from notification ID: %d" % notification_data.get_id())
	# Could navigate to specific screen based on notification ID
	# For now, just log it
