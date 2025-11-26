extends CharacterBody3D

# Enemy AI with waypoint patrol system
# Detects and damages the player on contact

@export var speed: float = 2.0
@export var detection_radius: float = 8.0
@export var damage: int = 1
@export var patrol_wait_time: float = 1.0

# Waypoints for patrolling
var waypoints: Array[Vector3] = []
var current_waypoint_index: int = 0
var waiting: bool = false
var wait_timer: float = 0.0

# Enemy state
enum State { PATROL, CHASE, WAIT }
var current_state: State = State.PATROL

# Animations
enum {IDLE, WALK}
var curAnim = IDLE
@export var blend_speed: int = 15
var walk_val := 0.0

# References
var player: CharacterBody3D = null
@onready var mob: Node3D = $Mob
@onready var animation_tree: AnimationTree = $Mob/AnimationTree


# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	add_to_group("enemies")
	
	# Setup collision
	collision_layer = 2  # Layer 2 for enemies
	collision_mask = 1   # Detect layer 1 (player)
	
	# If no waypoints set, create default patrol around spawn point
	if waypoints.is_empty():
		create_default_waypoints()

func create_default_waypoints():
	# Create a square patrol pattern around the spawn point
	var patrol_radius = 6.0
	waypoints = [
		position + Vector3(patrol_radius, 0, 0),
		position + Vector3(patrol_radius, 0, patrol_radius),
		position + Vector3(0, 0, patrol_radius),
		position + Vector3(-patrol_radius, 0, patrol_radius),
		position + Vector3(-patrol_radius, 0, 0),
		position + Vector3(-patrol_radius, 0, -patrol_radius),
		position + Vector3(0, 0, -patrol_radius),
		position + Vector3(patrol_radius, 0, -patrol_radius),
	]

func set_waypoints(new_waypoints: Array[Vector3]):
	waypoints = new_waypoints
	current_waypoint_index = 0

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	# Find player if not already found
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	# Update AI based on state
	match current_state:
		State.PATROL:
			patrol_behavior(delta)
		State.CHASE:
			chase_behavior(delta)
		State.WAIT:
			wait_behavior(delta)
	
	handle_animations(delta)
	update_tree()
	
	move_and_slide()
	
	# Check for collision with player
	check_player_collision()

# Definition for animations
func handle_animations(delta):
	match curAnim:
		IDLE:
			walk_val = lerpf(walk_val, 0, blend_speed*delta)
		WALK:
			walk_val = lerpf(walk_val, 1, blend_speed*delta)

# Update the blend value
func update_tree():
	animation_tree["parameters/Walk/blend_amount"] =walk_val
	
func patrol_behavior(_delta):
	if waypoints.is_empty():
		return
	
	# Check if player is in detection range
	if player and global_position.distance_to(player.global_position) < detection_radius:
		current_state = State.CHASE
		return
	
	# Move towards current waypoint
	var target = waypoints[current_waypoint_index]
	var direction = (target - global_position).normalized()
	direction.y = 0  # Keep movement horizontal
	
	if direction.length() > 0:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		curAnim = WALK
		
		# Rotate to face movement direction
		if mob:
			mob.look_at(global_position + direction, Vector3.UP)
	
	# Check if reached waypoint
	if global_position.distance_to(target) < 0.5:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()
		current_state = State.WAIT
		wait_timer = patrol_wait_time

func chase_behavior(_delta):
	if not player:
		current_state = State.PATROL
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# If player too far, return to patrol
	if distance_to_player > detection_radius * 1.5:
		current_state = State.PATROL
		curAnim = IDLE
		return
	
	# Chase player
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	
	if direction.length() > 0:
		velocity.x = direction.x * speed * 1.3  # Chase slightly faster
		velocity.z = direction.z * speed * 1.3
		curAnim = WALK
		
		# Rotate to face player
		if mob:
			mob.look_at(player.global_position, Vector3.UP)
			mob.rotate_y(deg_to_rad(180))

func wait_behavior(delta):
	velocity.x = 0
	velocity.z = 0
	curAnim = IDLE
	
	wait_timer -= delta
	if wait_timer <= 0:
		current_state = State.PATROL

func check_player_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.is_in_group("player"):
			damage_player(collider)
			animation_tree.set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func damage_player(player_node):
	if player_node.has_method("take_damage"):
		player_node.take_damage(damage)

func take_damage(_amount: int):
	# Enemies can be damaged by future power-ups or weapons
	queue_free()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		current_state = State.CHASE

func _on_detection_area_body_exited(body):
	if body.is_in_group("player"):
		current_state = State.PATROL
