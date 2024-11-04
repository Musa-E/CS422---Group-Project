extends RigidBody2D

# todo:: Help me
@export_range(0, 2) var rope_segment_length: float
@export_range(0, 1) var rope_segment_height: float
@onready var collision_circle: CircleShape2D = $CollisionShape2D.shape
@onready var joint: Node2D = $"../Joint"
@onready var velocity_dir: Node2D = $"../VelocityDirection"
@onready var string_segments := $StringSegments
@onready var rope_segments: Array[RigidBody2D] = []
@onready var debug_segments: int = 0


var last_rotation = Vector2.ZERO

func create_new_rope_segment(size: Vector2) -> RigidBody2D:
	# define the new box
	var rope_segment := RigidBody2D.new()
	#var rope_polygon := 
	var rope_box := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	rope_box.shape = shape
	#rope_segment.add_child(rope_box)
	return rope_segment
	
## Process physics on the yarn. When this method is called, a new segment of
## string should be attached to a the yarn.
func _physics_process(delta: float) -> void:
	# PinJoint follows behind the yarn based on the velocity
	var interp_location = linear_velocity.normalized()
	var interp_angle = lerp_angle(joint.rotation, interp_location.angle() - PI/2, 0.5)
	joint.rotation = interp_angle
	joint.global_position = global_position
	
	velocity_dir.rotation = linear_velocity.normalized().angle()
	velocity_dir.global_position = global_position
	
	# todo:: The math here is not exactly what I'm looking for, the segments are
	#        too small / there are not enough segments being created for how fast
	#        the ball is rolling
	var angle = transform.x.normalized().angle_to(last_rotation.normalized())
	var arc_len = angle * 2 * PI * collision_circle.radius
	var createNewSegment = (arc_len >= rope_segment_length)

	if createNewSegment:
		debug_segments += 1
		print("Created new rope segment ", debug_segments)
		last_rotation = transform.x.normalized()
		var new_joint := PinJoint2D.new()
		var segment = create_new_rope_segment(Vector2(rope_segment_length, rope_segment_height))
		#string_segments.add_child(segment)
		#rope_segments.append(segment)
	
