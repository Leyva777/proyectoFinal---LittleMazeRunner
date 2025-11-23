extends CharacterBody3D

# Player movement and control script
# Handles WASD movement, mouse camera rotation, health system, and collisions

# Movement parameters
@export var speed: float = 7.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 10.0
@export var friction: float = 15.0
@export var jump_velocity: float = 4.5 #4.5 normal

# Camera parameters
@export var mouse_sensitivity: float = 0.003
@export var camera_min_angle: float = -60.0
@export var camera_max_angle: float = 60.0

# Health system
@export var max_health: int = 3
var current_health: int = 3
var is_invulnerable: bool = false
var invulnerability_duration: float = 2.0

# Power-up states
var speed_boost_active: bool = false
var speed_boost_timer: float = 0.0
var speed_boost_duration: float = 5.0

# References
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

# Game state
var is_game_over: bool = false

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Capture mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	current_health = max_health
	
	# Emit signal to update UI
	if has_signal("health_changed"):
		emit_signal("health_changed", current_health)

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
	
	# Update power-up timers
	update_powerups(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		
	
	# Get input direction
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Determine current speed (with sprint and power-ups)
	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	if speed_boost_active:
		current_speed *= 1.5
	
	# Apply movement with acceleration/friction
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
	
	move_and_slide()

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
