extends Control

# Minimap system - Shows player position, collectibles, goal, and enemies

@export var map_size: Vector2 = Vector2(200, 200)
@export var zoom: float = 3.0

var player: Node3D
var maze_generator: Node3D
var map_scale: float = 1.0

# Colors
var player_color: Color = Color(0.2, 0.8, 1.0)  # Blue
var collectible_color: Color = Color(1.0, 0.9, 0.2)  # Yellow
var goal_color: Color = Color(0.3, 1.0, 0.3)  # Green
var enemy_color: Color = Color(1.0, 0.3, 0.3)  # Red
var powerup_color: Color = Color(1.0, 0.6, 1.0)  # Magenta
var wall_color: Color = Color(0.5, 0.5, 0.5, 0.3)  # Gray semi-transparent

func _ready():
	# Find references
	await get_tree().create_timer(0.3).timeout
	player = get_tree().get_first_node_in_group("player")
	maze_generator = get_tree().get_first_node_in_group("maze_generator")
	
	if maze_generator:
		var maze_size = maze_generator.maze_size * maze_generator.cell_size
		map_scale = map_size.x / (maze_size * zoom)

func _draw():
	if not player or not maze_generator:
		return
	
	# Draw background
	draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.1, 0.1, 0.15, 0.8))
	
	# Draw walls (simplified)
	draw_walls()
	
	# Draw goal
	draw_goal()
	
	# Draw collectibles
	draw_collectibles()
	
	# Draw power-ups
	draw_powerups()
	
	# Draw enemies
	draw_enemies()
	
	# Draw player
	draw_player()
	
	# Draw border
	draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.3, 0.3, 0.4), false, 2.0)
	
	# Draw legend
	draw_legend()

func _process(_delta):
	queue_redraw()  # Redraw every frame to update positions

func world_to_map(world_pos: Vector3) -> Vector2:
	var map_center = map_size / 2
	var relative_pos = Vector2(world_pos.x, world_pos.z) * map_scale
	return map_center + relative_pos - Vector2(maze_generator.maze_size * maze_generator.cell_size / 2 * map_scale, maze_generator.maze_size * maze_generator.cell_size / 2 * map_scale)

func draw_player():
	if not player:
		return
	
	var map_pos = world_to_map(player.global_position)
	
	# Draw direction indicator (triangle)
	var forward = -player.global_transform.basis.z
	var angle = atan2(forward.x, forward.z)
	
	var points: PackedVector2Array = [
		map_pos + Vector2(0, -8).rotated(angle),
		map_pos + Vector2(-5, 5).rotated(angle),
		map_pos + Vector2(5, 5).rotated(angle)
	]
	
	draw_colored_polygon(points, player_color)
	draw_circle(map_pos, 6, Color(1, 1, 1, 0.5))

func draw_collectibles():
	var collectibles = get_tree().get_nodes_in_group("collectibles")
	
	for collectible in collectibles:
		if collectible is Node3D:
			var map_pos = world_to_map(collectible.global_position)
			draw_circle(map_pos, 4, collectible_color)
			draw_circle(map_pos, 4, Color(1, 1, 1, 0.3), false, 1.5)

func draw_goal():
	if not maze_generator:
		return
	
	var goal_pos_3d = Vector3(
		maze_generator.goal_pos.x * maze_generator.cell_size + maze_generator.cell_size / 2,
		0,
		maze_generator.goal_pos.y * maze_generator.cell_size + maze_generator.cell_size / 2
	)
	
	var map_pos = world_to_map(goal_pos_3d)
	
	# Draw pulsing goal
	var pulse = (sin(Time.get_ticks_msec() / 200.0) + 1.0) / 2.0
	var radius = 6 + pulse * 3
	draw_circle(map_pos, radius, goal_color)
	draw_circle(map_pos, radius + 2, Color(1, 1, 1, 0.5), false, 2.0)

func draw_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if enemy is Node3D:
			var map_pos = world_to_map(enemy.global_position)
			draw_circle(map_pos, 5, enemy_color)
			draw_circle(map_pos, 5, Color(0, 0, 0, 0.5), false, 1.5)

func draw_powerups():
	var powerups = get_tree().get_nodes_in_group("powerups")
	
	for powerup in powerups:
		if powerup is Node3D:
			var map_pos = world_to_map(powerup.global_position)
			# Draw star shape for power-ups
			draw_circle(map_pos, 5, powerup_color)
			# Draw pulsing outline
			var pulse = (sin(Time.get_ticks_msec() / 150.0) + 1.0) / 2.0
			draw_circle(map_pos, 5 + pulse * 2, Color(1, 1, 1, 0.6), false, 1.5)

func draw_walls():
	if not maze_generator:
		return
	
	# Draw simplified wall representation
	var cell_size = maze_generator.cell_size
	var maze_size = maze_generator.maze_size
	
	for y in range(maze_size):
		for x in range(maze_size):
			var world_pos = Vector3(x * cell_size + cell_size / 2, 0, y * cell_size + cell_size / 2)
			var map_pos = world_to_map(world_pos)
			var cell_map_size = cell_size * map_scale
			
			# Draw cell as small square
			draw_rect(
				Rect2(map_pos - Vector2(cell_map_size / 2, cell_map_size / 2), Vector2(cell_map_size, cell_map_size)),
				Color(0.2, 0.2, 0.25, 0.5),
				false,
				0.5
			)

func draw_legend():
	# Draw title
	draw_string(ThemeDB.fallback_font, Vector2(10, -10), "MAPA", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1, 0.8))
	
	# Legend background
	var legend_height = 100
	draw_rect(Rect2(Vector2(0, -legend_height - 5), Vector2(map_size.x, legend_height)), Color(0.05, 0.05, 0.1, 0.9))
	
	var y_offset = -legend_height + 10
	var font = ThemeDB.fallback_font
	var font_size = 12
	
	# Player
	var points: PackedVector2Array = [
		Vector2(15, y_offset),
		Vector2(10, y_offset + 8),
		Vector2(20, y_offset + 8)
	]
	draw_colored_polygon(points, player_color)
	draw_string(font, Vector2(30, y_offset + 10), "Jugador", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	
	# Collectibles
	y_offset += 20
	draw_circle(Vector2(15, y_offset), 4, collectible_color)
	draw_string(font, Vector2(30, y_offset + 5), "Objetos", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	
	# Power-ups
	y_offset += 20
	draw_circle(Vector2(15, y_offset), 4, powerup_color)
	draw_string(font, Vector2(30, y_offset + 5), "Power-ups", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	
	# Goal
	y_offset += 20
	draw_circle(Vector2(15, y_offset), 5, goal_color)
	draw_string(font, Vector2(30, y_offset + 5), "Meta", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	
	# Enemies
	y_offset += 20
	draw_circle(Vector2(15, y_offset), 4, enemy_color)
	draw_string(font, Vector2(30, y_offset + 5), "Enemigos", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
