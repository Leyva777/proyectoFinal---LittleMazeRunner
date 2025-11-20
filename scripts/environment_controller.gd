extends Node3D

# Ambient lighting and atmosphere controller
# Adds ambient sounds and lighting effects

@onready var world_environment: WorldEnvironment = $WorldEnvironment

func _ready():
	setup_environment()

func setup_environment():
	if not world_environment:
		return
	
	# Create environment if it doesn't exist
	if not world_environment.environment:
		world_environment.environment = Environment.new()
	
	var env = world_environment.environment
	
	# Sky/Background
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.378, 0.22, 0.067, 1.0)  # Dark blue-gray
	
	# Ambient light
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.35, 0.4)
	env.ambient_light_energy = 0.5
	
	# Fog for atmosphere (optional)
	env.fog_enabled = true
	env.fog_light_color = Color(0.5, 0.55, 0.6)
	env.fog_density = 0.01
	env.fog_aerial_perspective = 0.5
	
	# Tone mapping
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.0
