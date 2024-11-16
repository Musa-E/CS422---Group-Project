extends Node2D

enum dir {
	FORWARD = 1,
	REVERSE = -1
}

@export var SPEED: float
@export var path: PathFollow2D
@export var direction: dir = dir.FORWARD
@export var platform: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_physics_process(false)
	if path != null:
		set_physics_process(true)

func _physics_process(_delta: float) -> void:
	path.progress_ratio += SPEED * direction
	platform.global_position = path.global_position
	
	if path.loop and (path.progress_ratio >= 1 or path.progress_ratio <= 0):
		return
		
	if path.progress_ratio >= 1 or path.progress_ratio <= 0:
		direction = -direction
		
	
