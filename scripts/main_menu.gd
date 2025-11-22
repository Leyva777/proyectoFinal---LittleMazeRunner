extends Control

# Main Menu - Initial screen with game options

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel

var title_animation_time: float = 0.0

func _ready():
	# Show mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Connect button signals
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
		play_button.mouse_entered.connect(_on_button_hover.bind(play_button))
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
		quit_button.mouse_entered.connect(_on_button_hover.bind(quit_button))
	
	# Focus on play button
	if play_button:
		play_button.grab_focus()

func _process(delta):
	# Animate title with pulsing effect
	title_animation_time += delta
	if title_label:
		var scale_factor = 1.0 + sin(title_animation_time * 2.0) * 0.05
		title_label.scale = Vector2(scale_factor, scale_factor)

func _on_button_hover(_button: Button):
	# Play hover sound effect (when audio is implemented)
	pass

func _on_play_button_pressed():
	# Fade out effect (optional)
	print("Starting game...")
	# Load main game scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed():
	print("Quitting game...")
	# Quit the game
	get_tree().quit()
