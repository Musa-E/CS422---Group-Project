# Filename: MainMenu
# Author: Musa Elqaq
# Purpose: Basic control for main menu

extends Control

func _ready() -> void:
	AudioPlayer.play_music_level()


func _on_start_mouse_entered() -> void:
	$buttonHover.play()

# When start button is pressed
func _on_start_pressed() -> void:
	$buttonPressed.play()
	AudioPlayer.play_tutorial_level() # Change to space-y music
	get_tree().change_scene_to_file("res://tutorial.tscn")



func _on_continue_mouse_entered() -> void:
	$buttonHover.play()

# When continue button is pressed
func _on_continue_pressed() -> void:
	$buttonPressed.play()
	get_tree().change_scene_to_file("res://Levels/levels.tscn")


func _on_settings_mouse_entered() -> void:
	$buttonHover.play()

# When settings button is pressed
func _on_settings_pressed() -> void:
	$buttonPressed.play()
	get_tree().change_scene_to_file("res://UI/settings.tscn")



func _on_exit_mouse_entered() -> void:
	$buttonHover.play()

# Exit the game
func _on_exit_pressed() -> void:
	get_tree().quit()
