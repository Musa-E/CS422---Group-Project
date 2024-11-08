extends Area2D

@export var pin_body: PhysicsBody2D

var can_pin = true

# when a rope segment collides with the yarn pin, stick the two together.
func _on_body_entered(body: Node2D) -> void:
	# guard clause babyyyyyyyyyy
	if not can_pin:
		return
		
	# create a new pin joint and attach the two bodies together at the point of contact.
	var joint := PinJoint2D.new()
	add_child(joint)
	pin_body.global_position = body.global_position
	joint.global_position = body.global_position
	joint.bias = 0
	joint.node_a = pin_body.get_path()
	joint.node_b = body.get_path()
	
