extends Node2D

signal activated(name: String)

@export var active: bool = false
@export var key: Keys
@export var button_polygon: Polygon2D

enum Keys {
	Wind,
	Earth,
	Fire,
	Water
}

func _on_area_2d_body_entered(body: Node2D) -> void:
	if active:
		return
	emit_signal("activated", str(Keys.keys()[key]))
	active = true
	button_polygon.color = Color.WEB_GREEN
