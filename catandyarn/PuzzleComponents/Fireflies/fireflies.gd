extends CPUParticles2D

@export var area: Area2D

var collected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# update firefly counter when connected then disable the thingy
func _on_area_body_entered(body: Node2D) -> void:
	if collected:
		return
		
	# yes I know this is horrible but I have no time
	collected = true
	var ffc = get_node("/root/FireFliesCollected")
	ffc.update_counter(ffc.count + 1)
