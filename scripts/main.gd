extends Node3D

# Main scene controller
# Initializes and coordinates all game systems

@onready var maze_generator = $MazeGenerator
@onready var player = $Player
@onready var hud = $HUD
@onready var game_manager = $GameManager

var collectible_scene = preload("res://scenes/collectible.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")
var powerup_scene = preload("res://scenes/powerup.tscn")

func _ready():
	# Wait for maze to generate
	await get_tree().create_timer(0.2).timeout
	
	# Position player at start
	if player and maze_generator:
		var start_pos = maze_generator.get_start_position()
		# Ensure player is above the floor
		start_pos.y = 2.0  # Height above floor
		player.position = start_pos
		player.add_to_group("player")
	
	# Spawn collectibles
	spawn_collectibles()
	
	# Spawn enemies
	spawn_enemies()
	
	# Spawn power-ups
	spawn_powerups()
	
	# Initialize game manager
	var collectible_count = get_tree().get_nodes_in_group("collectibles").size()
	game_manager.initialize(player, hud, collectible_count)

func spawn_collectibles():
	var num_collectibles = 10
	
	for i in range(num_collectibles):
		var collectible = collectible_scene.instantiate()
		var spawn_pos = maze_generator.get_random_free_position()
		collectible.position = spawn_pos
		add_child(collectible)

func spawn_enemies():
	var num_enemies = 2
	
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var spawn_pos = maze_generator.get_random_free_position()
		enemy.position = spawn_pos
		add_child(enemy)

func spawn_powerups():
	# Spawn 3 power-ups of different types
	var powerup_types = [0, 1, 2]  # SPEED, INVINCIBILITY, HEALTH
	
	for type in powerup_types:
		var powerup = powerup_scene.instantiate()
		powerup.power_up_type = type
		var spawn_pos = maze_generator.get_random_free_position()
		powerup.position = spawn_pos
		add_child(powerup)
