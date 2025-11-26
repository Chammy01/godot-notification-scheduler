#
# © 2024-present https://github.com/cengiz-pz
#
# MainMenu - Entry point for the notification integration demo
# Shows the proper setup and status of NotificationManager
#

extends Control

@onready var status_label: Label = $CanvasLayer/CenterContainer/VBoxContainer/StatusLabel
@onready var permissions_button: Button = $CanvasLayer/CenterContainer/VBoxContainer/ButtonsVBox/PermissionsButton


func _ready() -> void:
	print("🎮 MainMenu: Ready")
	
	# Connect buttons
	$CanvasLayer/CenterContainer/VBoxContainer/ButtonsVBox/BingoBoardButton.pressed.connect(_on_bingo_board_pressed)
	$CanvasLayer/CenterContainer/VBoxContainer/ButtonsVBox/OriginalDemoButton.pressed.connect(_on_original_demo_pressed)
	$CanvasLayer/CenterContainer/VBoxContainer/ButtonsVBox/PermissionsButton.pressed.connect(_on_permissions_pressed)
	$CanvasLayer/CenterContainer/VBoxContainer/ButtonsVBox/SettingsButton.pressed.connect(_on_settings_pressed)
	
	# Connect to NotificationManager signals for reactive updates
	if NotificationManager and NotificationManager.notification_scheduler:
		NotificationManager.notification_scheduler.permission_granted.connect(_on_permission_status_changed)
		NotificationManager.notification_scheduler.permission_denied.connect(_on_permission_status_changed)
	
	# Wait a frame for NotificationManager to initialize
	await get_tree().process_frame
	_update_status()


func _on_permission_status_changed(_permission_name: String = "") -> void:
	# Update status when permission state changes
	if is_inside_tree():
		_update_status()


func _update_status() -> void:
	if not NotificationManager:
		status_label.text = "❌ NotificationManager not found!"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	if not NotificationManager.initialization_completed:
		status_label.text = "🔄 NotificationManager initializing..."
		status_label.add_theme_color_override("font_color", Color.YELLOW)
		# Check again after a delay with a maximum of 5 retries
		_retry_status_check()
		return
	
	if NotificationManager.permission_granted:
		status_label.text = "✅ Notifications enabled and ready!"
		status_label.add_theme_color_override("font_color", Color.GREEN)
		permissions_button.disabled = true
		permissions_button.text = "✅ Permissions Granted"
	else:
		status_label.text = "⚠️ Notification permissions not granted"
		status_label.add_theme_color_override("font_color", Color.ORANGE)
		permissions_button.disabled = false
		permissions_button.text = "🔔 Request Permissions"


var _status_check_retries: int = 0
const MAX_STATUS_CHECK_RETRIES: int = 5

func _retry_status_check() -> void:
	_status_check_retries += 1
	if _status_check_retries >= MAX_STATUS_CHECK_RETRIES:
		status_label.text = "❌ Initialization timeout"
		status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	await get_tree().create_timer(0.5).timeout
	if is_inside_tree() and NotificationManager and not NotificationManager.initialization_completed:
		_update_status()


func _on_bingo_board_pressed() -> void:
	print("📋 MainMenu: Opening Bingo Board")
	get_tree().change_scene_to_file("res://bingo_board.tscn")


func _on_original_demo_pressed() -> void:
	print("🧪 MainMenu: Opening Original Demo")
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_permissions_pressed() -> void:
	if NotificationManager:
		print("🔔 MainMenu: Requesting notification permissions")
		NotificationManager.request_notification_permission()
		# Status will be updated via signal connection


func _on_settings_pressed() -> void:
	if NotificationManager:
		print("⚙️ MainMenu: Opening app settings")
		NotificationManager.open_notification_settings()
