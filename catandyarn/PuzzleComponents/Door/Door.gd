extends Node2D
@export var body: StaticBody2D
@export var collider: CollisionShape2D
@export var button_area: Area2D

## What the button connects to. Must have an "activate" function on it
@export var connection: Node2D

#func _ready() -> void:
	#button_area.connect("body_entered")

func activate(body: Node2D) -> void:
	queue_free()
	#collider.call_deferred((isabled = true
	body.collision_layer = 0
	visible = false
