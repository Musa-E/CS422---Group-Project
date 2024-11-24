extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_music_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_to_main_menu_pressed() -> void:
	$buttonPressed.play()
	get_tree().change_scene_to_file("res://UI/MainMenu.tscn")


func _on_back_to_main_menu_mouse_entered() -> void:
	$buttonHover.play()
