extends Control

# HUD - User Interface for displaying game information

# UI Elements references
@onready var health_label: Label = $MarginContainer/VBoxContainer/HealthLabel
@onready var collectibles_label: Label = $MarginContainer/VBoxContainer/CollectiblesLabel
@onready var message_label: Label = $MessageLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var victory_panel: Panel = $VictoryPanel
@onready var pause_menu: Panel = $PauseMenu

var message_timer: float = 0.0

func _ready():
	# Add to group for power-up messages
	add_to_group("hud")
	
	# Hide end game panels
	if game_over_panel:
		game_over_panel.visible = false
	if victory_panel:
		victory_panel.visible = false
	if pause_menu:
		pause_menu.visible = false
	
	# Hide message label initially
	if message_label:
		message_label.visible = false
	
	# Connect button signals manually to ensure they work
	connect_buttons()

func connect_buttons():
	# Game Over buttons
	if game_over_panel:
		var restart_btn = game_over_panel.get_node_or_null("VBoxContainer/RestartButton")
		var quit_btn = game_over_panel.get_node_or_null("VBoxContainer/QuitButton")
		if restart_btn and not restart_btn.pressed.is_connected(_on_restart_button_pressed):
			restart_btn.pressed.connect(_on_restart_button_pressed)
		if quit_btn and not quit_btn.pressed.is_connected(_on_quit_button_pressed):
			quit_btn.pressed.connect(_on_quit_button_pressed)
	
	# Victory buttons
	if victory_panel:
		var restart_btn = victory_panel.get_node_or_null("VBoxContainer/RestartButton")
		var quit_btn = victory_panel.get_node_or_null("VBoxContainer/QuitButton")
		if restart_btn and not restart_btn.pressed.is_connected(_on_restart_button_pressed):
			restart_btn.pressed.connect(_on_restart_button_pressed)
		if quit_btn and not quit_btn.pressed.is_connected(_on_quit_button_pressed):
			quit_btn.pressed.connect(_on_quit_button_pressed)
	
	# Pause menu buttons
	if pause_menu:
		var resume_btn = pause_menu.get_node_or_null("VBoxContainer/ResumeButton")
		var restart_btn = pause_menu.get_node_or_null("VBoxContainer/RestartButton")
		var quit_btn = pause_menu.get_node_or_null("VBoxContainer/QuitButton")
		if resume_btn and not resume_btn.pressed.is_connected(_on_resume_button_pressed):
			resume_btn.pressed.connect(_on_resume_button_pressed)
		if restart_btn and not restart_btn.pressed.is_connected(_on_restart_button_pressed):
			restart_btn.pressed.connect(_on_restart_button_pressed)
		if quit_btn and not quit_btn.pressed.is_connected(_on_quit_button_pressed):
			quit_btn.pressed.connect(_on_quit_button_pressed)

func _process(delta):
	# Message timer countdown
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0 and message_label:
			message_label.visible = false
	
	# Toggle pause menu
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func update_health(current_health: int):
	if health_label:
		health_label.text = "Health: " + str(current_health) + " ❤"

func update_collectibles(current: int, total: int):
	if collectibles_label:
		collectibles_label.text = "Items: %d / %d" % [current, total]

func show_message(text: String, duration: float = 3.0):
	if message_label:
		message_label.text = text
		message_label.visible = true
		message_timer = duration

func show_game_over():
	if game_over_panel:
		game_over_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func show_victory():
	if victory_panel:
		victory_panel.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func toggle_pause():
	print("Toggle pause called!")  # Debug
	
	# Don't pause if game is over or won
	if game_over_panel and game_over_panel.visible:
		print("Game over panel visible, ignoring pause")
		return
	if victory_panel and victory_panel.visible:
		print("Victory panel visible, ignoring pause")
		return
	
	if pause_menu:
		pause_menu.visible = !pause_menu.visible
		get_tree().paused = pause_menu.visible
		print("Pause menu visible: ", pause_menu.visible)
		print("Game tree paused: ", get_tree().paused)
		
		if pause_menu.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Button callbacks
func _on_restart_button_pressed():
	print("Restart button pressed!")  # Debug
	get_tree().paused = false
	# Get the GameManager directly
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("restart_game"):
		game_manager.restart_game()
	else:
		# Fallback: direct scene reload
		get_tree().reload_current_scene()

func _on_quit_button_pressed():
	print("Quit button pressed!")  # Debug
	get_tree().paused = false
	# Get the GameManager directly
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.has_method("quit_game"):
		game_manager.quit_game()
	else:
		# Fallback: direct quit
		get_tree().quit()

func _on_resume_button_pressed():
	print("Resume button pressed!")  # Debug
	toggle_pause()
