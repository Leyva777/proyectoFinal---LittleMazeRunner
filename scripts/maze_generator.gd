extends Node3D

# Maze generator using recursive backtracking algorithm
# Creates a 15x15 maze with multiple paths to the goal

@export var maze_size: int = 25
@export var cell_size: float = 8.0
@export var wall_height: float = 10.0
@export var wall_thickness: float = 0.4

# Colors/Materials
var wall_material: StandardMaterial3D
var floor_material: StandardMaterial3D
var goal_material: StandardMaterial3D

# Preload textures
var brick_texture = preload("res://assets/materials/brickWall.png")
var floor_texture = preload("res://assets/materials/floor.png")

# Maze data structure
var maze_grid: Array = []
var start_pos: Vector2i = Vector2i(0, 0)
var goal_pos: Vector2i

# Directions: North, East, South, West
const DIRECTIONS = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

func _ready():
	add_to_group("maze_generator")
	setup_materials()
	generate_maze()
	build_maze_geometry()

func setup_materials():
	# Create wall material with brick texture
	wall_material = StandardMaterial3D.new()
	wall_material.albedo_texture = brick_texture
	wall_material.uv1_scale = Vector3(1.5, 1.5, 1.0)
	wall_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	wall_material.roughness = 0.9
	
	# Floor material with texture
	floor_material = StandardMaterial3D.new()
	floor_material.albedo_texture = floor_texture
	floor_material.uv1_scale = Vector3(2.0, 2.0, 1.0)
	floor_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	floor_material.roughness = 0.85
	
	# Goal material (bright green with glow)
	goal_material = StandardMaterial3D.new()
	goal_material.albedo_color = Color(0.2, 1.0, 0.3)
	goal_material.emission_enabled = true
	goal_material.emission = Color(0.2, 1.0, 0.3)
	goal_material.emission_energy = 1.5
	goal_material.emission_operator = BaseMaterial3D.EMISSION_OP_ADD

func generate_maze():
	# Initialize grid with all walls
	maze_grid.clear()
	for y in range(maze_size):
		var row = []
		for x in range(maze_size):
			# Store walls: [north, east, south, west, visited]
			row.append([true, true, true, true, false])
		maze_grid.append(row)
	
	# Set start and goal positions
	start_pos = Vector2i(0, 0)
	goal_pos = Vector2i(maze_size - 1, maze_size - 1)
	
	# Generate maze using recursive backtracking
	var stack: Array = []
	var current = start_pos
	maze_grid[current.y][current.x][4] = true
	
	while true:
		var neighbors = get_unvisited_neighbors(current)
		
		if neighbors.size() > 0:
			# Choose random neighbor
			var next = neighbors[randi() % neighbors.size()]
			
			# Remove wall between current and next
			remove_wall_between(current, next)
			
			# Mark as visited and move
			maze_grid[next.y][next.x][4] = true
			stack.append(current)
			current = next
		elif stack.size() > 0:
			# Backtrack
			current = stack.pop_back()
		else:
			break
	
	# Create additional paths for multiple routes (30% chance to remove extra walls)
	create_additional_paths()

func get_unvisited_neighbors(pos: Vector2i) -> Array:
	var neighbors = []
	for dir in DIRECTIONS:
		var new_pos = pos + dir
		if is_valid_cell(new_pos) and not maze_grid[new_pos.y][new_pos.x][4]:
			neighbors.append(new_pos)
	return neighbors

func is_valid_cell(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < maze_size and pos.y >= 0 and pos.y < maze_size

func remove_wall_between(from: Vector2i, to: Vector2i):
	var diff = to - from
	
	if diff.y == -1:  # North
		maze_grid[from.y][from.x][0] = false
		maze_grid[to.y][to.x][2] = false
	elif diff.x == 1:  # East
		maze_grid[from.y][from.x][1] = false
		maze_grid[to.y][to.x][3] = false
	elif diff.y == 1:  # South
		maze_grid[from.y][from.x][2] = false
		maze_grid[to.y][to.x][0] = false
	elif diff.x == -1:  # West
		maze_grid[from.y][from.x][3] = false
		maze_grid[to.y][to.x][1] = false

func create_additional_paths():
	# Remove some random walls to create multiple paths
	var walls_to_remove = int(maze_size * maze_size * 0.15)  # Remove 15% extra walls
	
	for i in range(walls_to_remove):
		var x = randi() % maze_size
		var y = randi() % maze_size
		var wall_dir = randi() % 4
		
		# Check if we can remove this wall
		var neighbor_pos = Vector2i(x, y) + DIRECTIONS[wall_dir]
		if is_valid_cell(neighbor_pos):
			remove_wall_between(Vector2i(x, y), neighbor_pos)

func build_maze_geometry():
	# Create floor
	create_floor()
	
	# Create walls
	for y in range(maze_size):
		for x in range(maze_size):
			var cell_pos = Vector3(x * cell_size, 0, y * cell_size)
			var cell = maze_grid[y][x]
			
			# North wall
			if cell[0]:
				create_wall(cell_pos + Vector3(cell_size / 2, wall_height / 2, 0), Vector3(cell_size, wall_height, wall_thickness))
			
			# East wall
			if cell[1]:
				create_wall(cell_pos + Vector3(cell_size, wall_height / 2, cell_size / 2), Vector3(wall_thickness, wall_height, cell_size))
			
			# South wall
			if cell[2]:
				create_wall(cell_pos + Vector3(cell_size / 2, wall_height / 2, cell_size), Vector3(cell_size, wall_height, wall_thickness))
			
			# West wall
			if cell[3]:
				create_wall(cell_pos + Vector3(0, wall_height / 2, cell_size / 2), Vector3(wall_thickness, wall_height, cell_size))
	
	# Create goal marker
	create_goal_marker()

func create_floor():
	# Create floor using modular cubes
	for y in range(maze_size):
		for x in range(maze_size):
			var floor_tile = create_floor_tile(x, y)
			add_child(floor_tile)

func create_floor_tile(x: int, y: int) -> StaticBody3D:
	var static_body = StaticBody3D.new()
	static_body.position = Vector3(x * cell_size + cell_size / 2, 0, y * cell_size + cell_size / 2)
	static_body.collision_layer = 1  # Layer 1 for static geometry
	static_body.collision_mask = 0    # Doesn't detect anything
	
	# Create mesh for floor
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(cell_size, 0.5, cell_size)
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = floor_material
	mesh_instance.position = Vector3(0, -0.25, 0)
	
	# Add collision shape
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(cell_size, 0.5, cell_size)
	collision_shape.shape = shape
	collision_shape.position = Vector3(0, -0.25, 0)
	
	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)
	
	return static_body

func create_wall(wall_position: Vector3, wall_size: Vector3):
	var static_body = StaticBody3D.new()
	static_body.position = wall_position
	static_body.collision_layer = 1  # Layer 1 for static geometry
	static_body.collision_mask = 0    # Doesn't detect anything
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = wall_size
	
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = wall_material
	
	# Add collision
	var collision_shape = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = wall_size
	collision_shape.shape = shape
	
	static_body.add_child(mesh_instance)
	static_body.add_child(collision_shape)
	add_child(static_body)

func create_goal_marker():
	var goal_world_pos = Vector3(
		goal_pos.x * cell_size + cell_size / 2,
		0.5,
		goal_pos.y * cell_size + cell_size / 2
	)
	
	# Create visual goal marker
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.top_radius = cell_size * 0.4
	cylinder_mesh.bottom_radius = cell_size * 0.4
	cylinder_mesh.height = 0.3
	
	mesh_instance.mesh = cylinder_mesh
	mesh_instance.material_override = goal_material
	mesh_instance.position = goal_world_pos
	add_child(mesh_instance)
	
	# Add area for goal detection
	var area = Area3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.radius = cell_size * 0.4
	shape.height = 2.0
	collision_shape.shape = shape
	
	area.add_child(collision_shape)
	area.position = goal_world_pos + Vector3(0, 1, 0)
	area.add_to_group("goal")
	area.body_entered.connect(_on_goal_reached)
	add_child(area)

func _on_goal_reached(body):
	if body.is_in_group("player"):
		get_tree().call_group("game_manager", "level_complete")

func get_random_free_position() -> Vector3:
	# Get a random position in the maze that's not start or goal
	var attempts = 0
	while attempts < 100:
		var x = randi() % maze_size
		var y = randi() % maze_size
		
		if Vector2i(x, y) != start_pos and Vector2i(x, y) != goal_pos:
			return Vector3(x * cell_size + cell_size / 2, 1.0, y * cell_size + cell_size / 2)
		
		attempts += 1
	
	# Fallback
	return Vector3(cell_size * 2, 1.0, cell_size * 2)

func get_start_position() -> Vector3:
	return Vector3(start_pos.x * cell_size + cell_size / 2, 1.5, start_pos.y * cell_size + cell_size / 2)
