# Audio player for global audio
#
# Based on tutorial by "Soma Animus" on youtube (linked here):
# https://www.youtube.com/watch?v=lILnUD3xph8

extends AudioStreamPlayer

const level_music = preload("res://assets/audio/music/catAndYarn-TitleOST3-v3.mp3")
const tutorial_music = preload("res://assets/audio/music/spaceTheme-v1.mp3")
var effect_vol = 0.0
var music_vol = 0.0


func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
		
	music_vol = volume;
	stream = music
	volume_db = music_vol
	#loop = true # Loop the music
	play()
	
func play_music_level():
	_play_music(level_music)

func play_tutorial_level():
	_play_music(tutorial_music)
	
func play_FX(stream: AudioStream, volume = 0.0):
	var fx_player = AudioStreamPlayer.new()
	effect_vol = volume;
	fx_player.stream = stream
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = effect_vol
	add_child(fx_player)
	fx_player.play()
	
	await fx_player.finished
	fx_player.queue_free()

func change_volume(volume = 0.0):
	music_vol = volume
	volume_db = music_vol  # Update global volume

func change_fx_volume(volume = 0.0):
	effect_vol = volume
	for child in get_children():
		if child.name == "FX_PLAYER":
			child.volume_db = effect_vol  # Update FX player volume

func change_music_volume(volume = 0.0):
	music_vol = volume
	volume_db = music_vol  # Update the music volume

func linear_to_db(value: float) -> float:
	# Ensure value is clamped between 0.01 and 1.0 to avoid issues with log10(0)
	value = clamp(value, 0.01, 1.0)
	return -80.0 + (80.0 * value)  # Linearly scale from -80 to 0 dB

func db_to_linear(db: float) -> float:
	# Ensure db is clamped between -80 and 0
	db = clamp(db, -80.0, 0.0)
	return (db + 80.0) / 80.0  # Map dB from -80 to 0 back to 0.0 to 1.0
