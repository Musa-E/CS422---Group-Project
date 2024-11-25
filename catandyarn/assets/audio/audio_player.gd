# Audio player for global audio
#
# Based on tutorial by "Soma Animus" on youtube (linked here):
# https://www.youtube.com/watch?v=lILnUD3xph8

extends AudioStreamPlayer

const level_music = preload("res://assets/audio/music/catAndYarn-TitleOST3-v3.mp3")
const tutorial_music = preload("res://assets/audio/music/spaceTheme-v1.mp3")

func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
		
	stream = music
	volume_db = volume
	play()
	
func play_music_level():
	_play_music(level_music)

func play_tutorial_level():
	_play_music(tutorial_music)

	
func play_FX(stream: AudioStream, volume = 0.0):
	var fx_player = AudioStreamPlayer.new()
	fx_player.stream = stream
	fx_player.name = "FX_PLAYER"
	fx_player.volume_db = volume
	add_child(fx_player)
	fx_player.play()
	
	await fx_player.finished
	fx_player.queue_free()
