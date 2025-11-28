extends CharacterBody3D

# Player movement and control script
# Handles WASD movement, mouse camera rotation, health system, and collisions

# Movement parameters
@export var speed: float = 10.0
@export var sprint_speed: float = 14.0
@export var acceleration: float = 12.0
@export var friction: float = 15.0
@export var jump_velocity: float = 7.0

# Camera parameters
@export var mouse_sensitivity: float = 0.003
@export var camera_min_angle: float = -60.0
@export var camera_max_angle: float = 40.0

# Health system
@export var max_health: int = 3
var current_health: int = 3
var is_invulnerable: bool = false
var invulnerability_duration: float = 2.0

# Power-up states
var speed_boost_active: bool = false
var speed_boost_timer: float = 0.0
var speed_boost_duration: float = 5.0

# Animations
enum {IDLE, WALK, RUN, JUMP}
var curAnim = IDLE
@export var blend_speed: int = 15
var jump_val := 0.0
var run_val := 0.0
var is_sprinting: bool = false

# References
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var animation_tree: AnimationTree = $Bunny/AnimationTree

# Camera collision
var camera_raycast: RayCast3D
var default_camera_distance: float = 8.0
var camera_collision_margin: float = 0.5


# Game state
var is_game_over: bool = false

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Capture mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_health = max_health
	
	# Setup camera collision raycast
	setup_camera_collision()
	
	# Emit signal to update UI
	if has_signal("health_changed"):
		emit_signal("health_changed", current_health)

func setup_camera_collision():
	# Create RayCast3D for camera collision detection
	camera_raycast = RayCast3D.new()
	camera_pivot.add_child(camera_raycast)
	camera_raycast.enabled = true
	camera_raycast.exclude_parent = true
	camera_raycast.collision_mask = 1  # Layer 1 (static geometry)
	# Set target point at default camera distance
	camera_raycast.target_position = Vector3(0, 0, default_camera_distance)

func _input(event):
	# Camera rotation with mouse
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate player horizontally
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate camera vertically (with limits)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x,
			deg_to_rad(camera_min_angle),
			deg_to_rad(camera_max_angle)
		)
	
	# Toggle mouse capture with ESC
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if is_game_over:
		return
	
	# Update camera collision
	adjust_camera_distance()
	
	# Manage the animations
	handle_animations(delta)
	update_tree()
	
	# Update power-up timers
	update_powerups(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Check if sprinting
	is_sprinting = Input.is_action_pressed("sprint")
	
	# Determine current speed (with sprint and power-ups)
	var current_speed = speed
	if is_sprinting:
		current_speed = sprint_speed
	if speed_boost_active:
		current_speed *= 1.5
	
	# Apply movement with acceleration and animations
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		if is_on_floor():
			if is_sprinting:
				curAnim = RUN  # Sprint animation
			else:
				curAnim = WALK  # Walk animation
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)
		velocity.z = move_toward(velocity.z, 0.0, current_speed)
		if is_on_floor():
			curAnim = IDLE
			
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		curAnim = JUMP
	elif Input.is_action_just_released("ui_accept") and velocity.y > 3.0:
		velocity.y *= 0.5
	
	# Return to ground animation after jump
	if not is_on_floor() and curAnim != JUMP:
		curAnim = JUMP
	
	move_and_slide()

func handle_animations(delta):
	match curAnim:
		IDLE:
			run_val = lerpf(run_val, 0, blend_speed*delta)
			jump_val = lerpf(jump_val, 0, blend_speed*delta)
		WALK:
			# Walk speed - medium blend
			run_val = lerpf(run_val, 0.5, blend_speed*delta)
			jump_val = lerpf(jump_val, 0, blend_speed*delta)
		RUN:
			# Sprint speed - full blend
			run_val = lerpf(run_val, 1, blend_speed*delta)
			jump_val = lerpf(jump_val, 0, blend_speed*delta)
		JUMP:
			# Keep current run value during jump for more natural transition
			jump_val = lerpf(jump_val, 1, blend_speed*delta)

func update_tree():
	animation_tree["parameters/Run/blend_amount"] = run_val
	animation_tree["parameters/Jump/blend_amount"] = jump_val

func adjust_camera_distance():
	# Check if raycast hits a wall
	if camera_raycast and camera_raycast.is_colliding():
		# Get collision point
		var collision_point = camera_raycast.get_collision_point()
		var collision_distance = camera_pivot.global_position.distance_to(collision_point)
		
		# Apply margin to prevent camera from being too close to wall
		var safe_distance = max(camera_collision_margin, collision_distance - camera_collision_margin)
		
		# Smoothly move camera to safe distance
		var current_z = camera.position.z
		camera.position.z = lerp(current_z, safe_distance, 0.2)
	else:
		# No collision, return to default distance smoothly
		camera.position.z = lerp(camera.position.z, default_camera_distance, 0.1)

func update_powerups(delta: float):
	# Speed boost timer
	if speed_boost_active:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			speed_boost_active = false

func take_damage(amount: int = 1):
	if is_invulnerable or is_game_over:
		return
	
	current_health -= amount
	current_health = max(0, current_health)
	
	# Emit signal to update UI
	get_tree().call_group("game_manager", "update_health", current_health)
	
	# Check for game over
	if current_health <= 0:
		game_over()
	else:
		# Start invulnerability period
		start_invulnerability()

func start_invulnerability():
	is_invulnerable = true
	# Visual feedback (optional flashing effect)
	var timer = get_tree().create_timer(invulnerability_duration)
	timer.timeout.connect(func(): is_invulnerable = false)

func heal(amount: int = 1):
	current_health = min(current_health + amount, max_health)
	get_tree().call_group("game_manager", "update_health", current_health)

func activate_speed_boost():
	speed_boost_active = true
	speed_boost_timer = speed_boost_duration
	get_tree().call_group("hud", "show_message", "Speed Boost for " + str(int(speed_boost_duration)) + " seconds!", 2.0)

func activate_invulnerability_powerup(duration: float = 5.0):
	is_invulnerable = true
	# Show visual feedback
	get_tree().call_group("hud", "show_message", "Invincible for " + str(int(duration)) + " seconds!", 2.0)
	
	# Create shield effect
	create_shield_effect()
	
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func(): 
		if not is_game_over:
			is_invulnerable = false
			remove_shield_effect()
	)

func create_shield_effect():
	# Create a visual shield sphere
	var shield = MeshInstance3D.new()
	shield.name = "ShieldEffect"
	add_child(shield)
	
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 1.2
	sphere_mesh.height = 2.4
	shield.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.8, 0.0, 0.3)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.8, 0.0, 1.0)
	material.emission_energy_multiplier = 2.0
	shield.material_override = material
	
	# Animate shield
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(shield, "scale", Vector3(1.1, 1.1, 1.1), 0.5)
	tween.tween_property(shield, "scale", Vector3(1.0, 1.0, 1.0), 0.5)

func remove_shield_effect():
	var shield = get_node_or_null("ShieldEffect")
	if shield:
		shield.queue_free()

func game_over():
	is_game_over = true
	velocity = Vector3.ZERO
	get_tree().call_group("game_manager", "player_died")

func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health
