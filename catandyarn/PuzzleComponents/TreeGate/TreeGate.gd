extends Node2D

@export var glow_duration: float

@export var activated_dict = {
	"Water": false,
	"Earth": false,
	"Fire": false,
	"Wind": false
}

var colors_dict = {
	"Water": [Color.NAVY_BLUE, Color.DARK_CYAN],
	"Earth": [Color.SADDLE_BROWN, Color.BURLYWOOD],
	"Fire": [Color.DARK_RED, Color.ORANGE_RED],
	"Wind": [Color.DARK_OLIVE_GREEN, Color.GREEN_YELLOW]
}

func start_glow(name: String) -> void:
	var polygon: Polygon2D = get_node(name)
	var tween = create_tween()
	tween.tween_property(polygon, "color", colors_dict[name][1], glow_duration)
	tween.tween_interval(0.5)
	tween.tween_property(polygon, "color", colors_dict[name][0], glow_duration)
	tween.set_loops()
	tween.parallel()
	activated_dict[name] = true
	tween.play()
