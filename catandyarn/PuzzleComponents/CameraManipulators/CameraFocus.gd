extends Node2D

@export var collision_shape: CollisionShape2D
@onready var collision_rect: Rect2 = collision_shape.shape.get_rect()
