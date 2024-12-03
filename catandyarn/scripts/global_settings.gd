# global_settings.gd
extends Node

# Default values
var master_volume = 1.0
var music_volume = 1.0
var effects_volume = 1.0

# Save slider states for volume
func save_settings(master: float, music: float, effects: float) -> void:
	master_volume = master
	music_volume = music
	effects_volume = effects
