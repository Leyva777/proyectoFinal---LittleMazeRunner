extends Area3D

# Collectible item script
# Handles visual effects, rotation, and collection

@export var points_value: int = 10
@export var rotation_speed: float = 2.0
@export var bob_height: float = 0.3
@export var bob_speed: float = 3.0

var start_y: float = 0.0
var time: float = 0.0

@onready var model: Node3D = $Model

func _ready():
	# Store initial height for bobbing animation
	start_y = position.y
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Add to collectibles group
	add_to_group("collectibles")
	
	# Setup collision layer
	collision_layer = 4  # Layer 3
	collision_mask = 1   # Detect layer 1 (player)

func _process(delta):
	time += delta
	
	# Rotate the collectible
	if model:
		model.rotate_y(rotation_speed * delta)
	
	# Bobbing animation
	position.y = start_y + sin(time * bob_speed) * bob_height

func _on_body_entered(body):
	if body.is_in_group("player"):
		collect()

func collect():
	# Notify game manager
	get_tree().call_group("game_manager", "collectible_picked", points_value)
	
	# Play collection effect (audio would go here)
	create_collection_effect()
	
	# Remove the collectible
	queue_free()

func create_collection_effect():
	# Create particles effect
	var particles = CPUParticles3D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 20
	particles.lifetime = 0.5
	particles.speed_scale = 2.0
	
	# Particle properties
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.3
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 45
	particles.gravity = Vector3(0, -5, 0)
	particles.initial_velocity_min = 2.0
	particles.initial_velocity_max = 4.0
	particles.scale_amount_min = 0.1
	particles.scale_amount_max = 0.2
	
	# Color gradient (yellow to transparent)
	particles.color = Color(1, 0.8, 0.2)
	
	# Add to scene
	get_parent().add_child(particles)
	particles.global_position = global_position
	
	# Auto-delete after lifetime
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)
