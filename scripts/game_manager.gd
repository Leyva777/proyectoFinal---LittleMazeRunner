extends Node

# Game Manager - Handles game state, score, and coordination between systems

# Game state
var total_collectibles: int = 10
var collected_items: int = 0
var player_health: int = 3
var is_game_over: bool = false
var is_victory: bool = false

# References
var player: CharacterBody3D
var hud: Control

# Signals
signal score_updated(current: int, total: int)
signal health_updated(current: int)
signal game_over
signal victory

func _ready():
	add_to_group("game_manager")

func initialize(player_ref: CharacterBody3D, hud_ref: Control, collectible_count: int):
	player = player_ref
	hud = hud_ref
	total_collectibles = collectible_count
	collected_items = 0
	is_game_over = false
	is_victory = false
	
	# Update UI
	update_score()
	update_health(player.get_health() if player else 3)

func collectible_picked(_points: int):
	if is_game_over or is_victory:
		return
	
	collected_items += 1
	update_score()
	
	# Check victory condition
	if collected_items >= total_collectibles:
		check_victory_condition()

func update_score():
	score_updated.emit(collected_items, total_collectibles)
	if hud and hud.has_method("update_collectibles"):
		hud.update_collectibles(collected_items, total_collectibles)

func update_health(health: int):
	player_health = health
	health_updated.emit(health)
	if hud and hud.has_method("update_health"):
		hud.update_health(health)

func player_died():
	if is_game_over:
		return
	
	is_game_over = true
	game_over.emit()
	
	if hud and hud.has_method("show_game_over"):
		hud.show_game_over()

func level_complete():
	if is_victory or is_game_over:
		return
	
	# Check if all collectibles were gathered
	if collected_items <= total_collectibles:
		is_victory = true
		victory.emit()
		
		if hud and hud.has_method("show_victory"):
			hud.show_victory()
	else:
		# Show message that player needs to collect all items
		if hud and hud.has_method("show_message"):
			hud.show_message("Collect all items first! (%d/%d)" % [collected_items, total_collectibles])

func check_victory_condition():
	# Victory happens when reaching goal after collecting all items
	# This is checked in level_complete()
	pass

func restart_game():
	is_game_over = false
	is_victory = false
	collected_items = 0
	get_tree().reload_current_scene()

func quit_game():
	get_tree().quit()

func pause_game():
	get_tree().paused = true

func resume_game():
	get_tree().paused = false
