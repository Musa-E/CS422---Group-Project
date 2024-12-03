extends Control

# tracks number of fireflies collected

@export var count: int
@export var max: int
@export var label: Label

func _ready() -> void:
	visible = false
	
func update_counter(amt: int) -> void:
	visible = true
	label.text = "Fireflies: %d/%d" % [amt, max]
