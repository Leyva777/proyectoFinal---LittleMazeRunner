extends Area3D

# Power-up base class
# Different types: SPEED, INVINCIBILITY, HEALTH

enum PowerUpType { SPEED, INVINCIBILITY, HEALTH }

@export var power_up_type: PowerUpType = PowerUpType.SPEED
@export var duration: float = 5.0
@export var rotation_speed: float = 2.0
@export var bob_height: float = 0.3
@export var bob_speed: float = 2.0

var time: float = 0.0
var initial_y: float = 0.0

@onready var model: Node3D = $Model
@onready var light: OmniLight3D = $OmniLight3D

func _ready():
	body_entered.connect(_on_body_entered)
	add_to_group("powerups")
	initial_y = position.y
	setup_appearance()
	create_particles()

func _process(delta):
	time += delta
	
	# Rotate power-up
	if model:
		model.rotate_y(rotation_speed * delta)
	
	# Floating animation (bobbing)
	position.y = initial_y + sin(time * bob_speed) * bob_height
	
	# Pulse light
	if light:
		light.light_energy = 1.5 + sin(time * 4.0) * 0.5

func setup_appearance():
	# Create omni light for glow effect
	if not light:
		light = OmniLight3D.new()
		add_child(light)
		light.omni_range = 3.0
		light.light_energy = 1.5
	
	# Set light color based on power-up type
	match power_up_type:
		PowerUpType.SPEED:
			light.light_color = Color(0.0, 0.5, 1.0)  # Blue
		PowerUpType.INVINCIBILITY:
			light.light_color = Color(1.0, 0.8, 0.0)  # Gold
		PowerUpType.HEALTH:
			light.light_color = Color(0.0, 1.0, 0.3)  # Green
	
	# Apply emission material to model
	apply_emission_material()

func apply_emission_material():
	if not model:
		return
	
	var emission_color: Color
	match power_up_type:
		PowerUpType.SPEED:
			emission_color = Color(0.0, 0.5, 1.0, 1.0)  # Blue
		PowerUpType.INVINCIBILITY:
			emission_color = Color(1.0, 0.8, 0.0, 1.0)  # Gold
		PowerUpType.HEALTH:
			emission_color = Color(0.0, 1.0, 0.3, 1.0)  # Green
	
	# Find all MeshInstance3D children and apply material
	for child in model.get_children():
		if child is MeshInstance3D:
			var material = StandardMaterial3D.new()
			material.albedo_color = emission_color
			material.emission_enabled = true
			material.emission = emission_color
			material.emission_energy_multiplier = 2.0
			child.material_override = material

func create_particles():
	# Create particle effect
	var particles = CPUParticles3D.new()
	add_child(particles)
	particles.emitting = true
	particles.amount = 16
	particles.lifetime = 1.5
	particles.explosiveness = 0.0
	particles.randomness = 0.5
	
	# Emission shape - sphere
	particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 0.3
	
	# Movement
	particles.direction = Vector3(0, 1, 0)
	particles.spread = 45.0
	particles.gravity = Vector3(0, 0.5, 0)
	particles.initial_velocity_min = 0.2
	particles.initial_velocity_max = 0.5
	
	# Appearance
	var particle_color: Color
	match power_up_type:
		PowerUpType.SPEED:
			particle_color = Color(0.0, 0.5, 1.0, 0.6)  # Blue
		PowerUpType.INVINCIBILITY:
			particle_color = Color(1.0, 0.8, 0.0, 0.6)  # Gold
		PowerUpType.HEALTH:
			particle_color = Color(0.0, 1.0, 0.3, 0.6)  # Green
	
	particles.color = particle_color
	particles.scale_amount_min = 0.1
	particles.scale_amount_max = 0.2

func _on_body_entered(body):
	if body.is_in_group("player"):
		apply_power_up(body)
		create_collection_effect()
		queue_free()

func apply_power_up(player):
	var message: String = ""
	
	match power_up_type:
		PowerUpType.SPEED:
			if player.has_method("activate_speed_boost"):
				player.activate_speed_boost()
				message = "Speed Boost!"
		PowerUpType.INVINCIBILITY:
			if player.has_method("activate_invulnerability_powerup"):
				player.activate_invulnerability_powerup(duration)
				message = "Invincibility!"
		PowerUpType.HEALTH:
			if player.has_method("heal"):
				player.heal(1)
				message = "+1 Health!"
	
	# Show message in HUD
	if message != "":
		get_tree().call_group("hud", "show_message", message, 2.0)

func create_collection_effect():
	# Create burst particles on collection
	var burst = CPUParticles3D.new()
	get_parent().add_child(burst)
	burst.global_position = global_position
	burst.emitting = true
	burst.one_shot = true
	burst.amount = 20
	burst.lifetime = 0.8
	burst.explosiveness = 1.0
	
	# Emission
	burst.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	burst.emission_sphere_radius = 0.1
	
	# Movement
	burst.direction = Vector3(0, 1, 0)
	burst.spread = 180.0
	burst.gravity = Vector3(0, -2, 0)
	burst.initial_velocity_min = 2.0
	burst.initial_velocity_max = 4.0
	
	# Color
	var particle_color: Color
	match power_up_type:
		PowerUpType.SPEED:
			particle_color = Color(0.0, 0.5, 1.0, 1.0)
		PowerUpType.INVINCIBILITY:
			particle_color = Color(1.0, 0.8, 0.0, 1.0)
		PowerUpType.HEALTH:
			particle_color = Color(0.0, 1.0, 0.3, 1.0)
	
	burst.color = particle_color
	burst.scale_amount_min = 0.15
	burst.scale_amount_max = 0.3
	
	# Auto-delete after lifetime
	await get_tree().create_timer(burst.lifetime).timeout
	burst.queue_free()
