# Filename: MainMenu
# Author: Musa Elqaq
# Purpose: Basic control for main menu

extends Control


# When start button is pressed
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial.tscn")

# When continue button is pressed
func _on_continue_pressed() -> void:
	pass # Replace with function body.

# When settings button is pressed
func _on_settings_pressed() -> void:
	pass # Replace with function body.


# Exit the game
func _on_exit_pressed() -> void:
	get_tree().quit()
