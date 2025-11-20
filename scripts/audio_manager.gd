extends Node

# Audio Manager - Centralized audio control
# Handles sound effects and background music

var audio_enabled: bool = true

# Audio player pools
var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

func _ready():
	# Create audio player pool for sound effects
	for i in range(5):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)
	
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

func play_sfx(stream: AudioStream, volume_db: float = 0.0):
	if not audio_enabled or not stream:
		return
	
	# Find available player
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	
	# If all busy, use first one
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = volume_db
	sfx_players[0].play()

func play_music(stream: AudioStream, volume_db: float = -10.0):
	if not audio_enabled or not stream:
		return
	
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()

func stop_music():
	if music_player:
		music_player.stop()

func set_master_volume(volume: float):
	AudioServer.set_bus_volume_db(0, linear_to_db(volume))

func toggle_audio():
	audio_enabled = !audio_enabled
	if not audio_enabled:
		stop_music()

# Placeholder sound effect names for when audio files are added
enum SFX {
	COLLECT,
	DAMAGE,
	POWERUP,
	VICTORY,
	GAME_OVER
}
