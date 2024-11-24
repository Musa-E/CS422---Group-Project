extends Node2D

@export var glow_duration: float

@export var activated_dict = {
	"Water": false,
	"Earth": false,
	"Fire": false,
	"Wind": false
}

func start_glow(name: String) -> void:
	var polygon: Polygon2D = get_node(name)
	var tween = create_tween()
	tween.tween_property(polygon, "color.v", 80, glow_duration)
	tween.tween_interval(0.5)
	tween.tween_property(polygon, "color.v", 35, glow_duration)
	tween.set_loops()
	tween.parallel()
	activated_dict[name] = true
