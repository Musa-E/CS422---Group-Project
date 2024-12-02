# Settings Script
#
#
# Volume slider & Screen Resolution based on this tutorial by "Gwizz":
# https://www.youtube.com/watch?v=lDMInA-Bb2k
#

extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_music_level()
	
	# Sync sliders with the current audio bus volumes
	$"MarginContainer/VBoxContainer/HBoxContainer/MasterSlider".value = db_to_linear(AudioServer.get_bus_volume_db(0))
	$"MarginContainer/VBoxContainer/HBoxContainer/MusicSlider".value = db_to_linear(AudioServer.get_bus_volume_db(1))
	$"MarginContainer/VBoxContainer/HBoxContainer/EffectsSlider".value = db_to_linear(AudioServer.get_bus_volume_db(2))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_to_main_menu_pressed() -> void:
	$buttonPressed.play()
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")


func _on_back_to_main_menu_mouse_entered() -> void:
	$buttonHover.play()


# Master volume slider
func _on_master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	AudioPlayer.change_volume(linear_to_db(value))

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	AudioPlayer.change_music_volume(linear_to_db(value))

func _on_effects_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	AudioPlayer.change_fx_volume(linear_to_db(value))




# Change the resolution of the game
func _on_resolutions_item_selected(index: int) -> void:
	match index:
		0:
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1:
			DisplayServer.window_set_size(Vector2i(1600,900))
		2:
			DisplayServer.window_set_size(Vector2i(1280,720))
