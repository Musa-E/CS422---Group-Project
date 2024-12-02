extends Node2D

@export var initial_obj: Node2D
@export var spawn_position: Node2D
@export var to_spawn: PackedScene = null

func _ready() -> void:
	if initial_obj != null:
		to_spawn = PackedScene.new()
		to_spawn.pack(initial_obj)

func activate(body: Node2D) -> void:
	if to_spawn == null:
		return
		
	initial_obj.queue_free()
	var instance = to_spawn.instantiate()
	get_tree().root.call_deferred("add_child", instance)
	instance.global_position = spawn_position.global_position
	initial_obj = instance
