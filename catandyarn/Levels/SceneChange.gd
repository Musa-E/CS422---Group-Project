extends Area2D

func change_scene(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://Levels/levels.tscn")
