extends Control

# tracks number of fireflies collected

@export var count: int = 0
@export var max: int
@export var label: Label

func _ready() -> void:
	visible = false
	
func update_counter(amt: int) -> void:
	visible = true
	count += amt
	label.text = "Fireflies: %d/%d" % [amt, max]
