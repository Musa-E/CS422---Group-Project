extends Node2D

@export var area: Area2D
@export var reset_point: Node2D
@export var audio_player: AudioStreamPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	body.global_position = reset_point.global_position
	audio_player.play()
