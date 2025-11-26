#
# © 2024-present https://github.com/cengiz-pz
#
# BingoBoard - UI controller for the bingo board demo
# Demonstrates notification triggers based on user interactions
#

extends Control

@onready var board_manager: Node = $BoardManager
@onready var task_input: LineEdit = $CanvasLayer/VBoxContainer/ActionsVBox/InputHBox/TaskInput
@onready var stats_label: Label = $CanvasLayer/VBoxContainer/StatsLabel
@onready var info_label: Label = $CanvasLayer/VBoxContainer/InfoLabel
@onready var grid_container: GridContainer = $CanvasLayer/VBoxContainer/GridContainer

var tile_buttons: Array[Button] = []


func _ready() -> void:
	print("🎮 BingoBoard: Ready")
	
	# Collect all tile buttons
	for i in range(9):
		var tile = grid_container.get_node("Tile%d" % i)
		if tile is Button:
			tile_buttons.append(tile)
			tile.pressed.connect(_on_tile_pressed.bind(i))
	
	# Connect UI signals
	$CanvasLayer/VBoxContainer/HeaderHBox/BackButton.pressed.connect(_on_back_pressed)
	$CanvasLayer/VBoxContainer/ActionsVBox/InputHBox/AddButton.pressed.connect(_on_add_task_pressed)
	$CanvasLayer/VBoxContainer/ActionsVBox/ButtonsHBox/ResetButton.pressed.connect(_on_reset_pressed)
	$CanvasLayer/VBoxContainer/ActionsVBox/ButtonsHBox/ScheduleButton.pressed.connect(_on_schedule_pressed)
	
	# Connect board manager signals
	board_manager.task_added.connect(_on_task_added)
	board_manager.task_completed.connect(_on_task_completed)
	board_manager.board_reset.connect(_on_board_reset)
	
	# Allow enter key to add task
	task_input.text_submitted.connect(_on_task_text_submitted)
	
	_update_ui()


func _on_add_task_pressed() -> void:
	var task_name = task_input.text.strip_edges()
	if task_name.is_empty():
		_show_info("⚠️ Please enter a task name!")
		return
	
	if board_manager.add_task(task_name):
		task_input.clear()
		_update_ui()
		_show_info("✅ Task added: '%s'" % task_name)
	else:
		_show_info("❌ Board is full!")


func _on_task_text_submitted(text: String) -> void:
	_on_add_task_pressed()


func _on_tile_pressed(tile_id: int) -> void:
	var task = board_manager.get_task(tile_id)
	if task.is_empty():
		_show_info("⚠️ No task in this tile!")
		return
	
	if task.completed:
		_show_info("ℹ️ Task already completed!")
		return
	
	# Complete the task
	if board_manager.complete_task(tile_id):
		_update_ui()
		_show_info("🎉 Task completed: '%s'" % task.name)
		
		# Check if all tasks are done
		if board_manager.get_completion_percentage() >= 100.0:
			_show_info("🎊 Congratulations! All tasks completed!")


func _on_reset_pressed() -> void:
	board_manager.reset_board()
	_update_ui()
	_show_info("🔄 Board reset!")


func _on_schedule_pressed() -> void:
	# Create some sample scheduled tasks for demo
	var today = Time.get_datetime_string_from_system()
	var sample_tasks = ["Morning Exercise", "Read 30 pages", "Review project"]
	board_manager.save_scheduled_tasks(today, sample_tasks)
	_show_info("📅 Scheduled %d tasks for today!" % sample_tasks.size())


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_task_added(task_name: String) -> void:
	# UI already updated via _update_ui in add_task
	pass


func _on_task_completed(task_name: String) -> void:
	# UI already updated via _update_ui in complete_task
	pass


func _on_board_reset() -> void:
	# UI already updated via _update_ui in reset_board
	pass


func _update_ui() -> void:
	var tasks = board_manager.get_all_tasks()
	var completed_count = 0
	
	# Update tiles
	for i in range(9):
		if i < tasks.size():
			var task = tasks[i]
			var button = tile_buttons[i]
			button.text = task.name
			
			if task.completed:
				button.modulate = Color(0.5, 1.0, 0.5)  # Green tint
				completed_count += 1
			else:
				button.modulate = Color(1.0, 1.0, 1.0)  # Normal
		else:
			tile_buttons[i].text = "+"
			tile_buttons[i].modulate = Color(1.0, 1.0, 1.0)
	
	# Update stats
	var completion = board_manager.get_completion_percentage()
	stats_label.text = "Tasks: %d/9 | Completed: %.0f%%" % [tasks.size(), completion]


func _show_info(message: String) -> void:
	info_label.text = message
	print("ℹ️ BingoBoard: " + message)
	
	# Reset info after 3 seconds
	await get_tree().create_timer(3.0).timeout
	if is_inside_tree():
		info_label.text = "💡 Tip: Add tasks to see notifications in action!"


## Debug function for testing notifications
func _input(event: InputEvent) -> void:
	if not OS.has_feature("editor"):
		return  # Only in editor for testing
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_N:
			# Test notification
			NotificationManager.schedule_custom_notification(
				5000,
				"🧪 Test Notification",
				"This is a test from the debug key!",
				5
			)
			_show_info("🧪 Test notification scheduled for 5 seconds!")
		elif event.keycode == KEY_M:
			# Test permission request
			if NotificationManager:
				NotificationManager.request_notification_permission()
				_show_info("🔔 Requesting notification permission...")
