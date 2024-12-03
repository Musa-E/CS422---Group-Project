extends CPUParticles2D

@export var area: Area2D

var collected: bool = false

# update firefly counter when connected then disable the thingy
func _on_area_body_entered(body: Node2D) -> void:
	if collected:
		return
	
	collected = true
	emitting = false
	## yes I know this is horrible but I have no time
	#collected = true
	#var ffc = get_node("/root/FireFliesCollected")
	#ffc.update_counter(1)
	#emitting = false
