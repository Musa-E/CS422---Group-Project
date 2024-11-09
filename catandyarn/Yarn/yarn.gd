extends Node2D

@export var rope_segment_scene: PackedScene = null
@export var on_start_segments: int = 1
# todo:: Get rope working then adjust the 
@export var rope_segment_length: float
#@export_range(0, 1) var rope_segment_height: float
@export var joint_parent: Node2D
@onready var initial_rope_segment: SoftBody2D = $"Joint/SoftBody2D"
@onready var initial_joint: PinJoint2D = $"Joint/PinJoint2D"
@onready var rope_segments: Array[SoftBody2D] = []
@onready var debug_segments: int = 0
@onready var yarn_body_component: RigidBody2D = $"Yarn"

var last_rotation = 0

func _ready() -> void:
	# set initial rope segment
	rope_segments.append(initial_rope_segment)
	initial_joint.node_a = yarn_body_component.get_path() # we are on the yarn
	initial_joint.node_b = initial_rope_segment.get_node("Bone-0").get_path()
	
	for n in range(1, on_start_segments):
		create_new_rope_segment()

func create_new_rope_segment() -> void:
	# define the new box
	var rope_segment := rope_segment_scene.instantiate()
	var next_pinjoint := PinJoint2D.new()
	joint_parent.add_child(next_pinjoint)
	joint_parent.add_child(rope_segment)
	rope_segments.append(rope_segment)
	next_pinjoint.global_position = rope_segments[-2].get_node("Bone-3").global_position
	rope_segment.global_position = next_pinjoint.global_position
	next_pinjoint.node_a = rope_segments[-2].get_node("Bone-3").get_path() # guaranteed to exist
	next_pinjoint.node_b = rope_segments[-1].get_node("Bone-0").get_path()
	rope_segments[-1].apply_impulse(rope_segments[-2].get_node("Bone-3").linear_velocity, rope_segments[-2].global_position)
	next_pinjoint.bias = 0.9
	
	debug_segments += 1
	print("Created new rope segment ", debug_segments)
	
func create_new_rope_segment_front() -> void:
	# define the new box
	var rope_segment := rope_segment_scene.instantiate()
	var next_pinjoint := PinJoint2D.new()
	joint_parent.add_child(next_pinjoint)
	joint_parent.add_child(rope_segment)
	next_pinjoint.global_position = rope_segments[0].get_node("Bone-0").global_position
	rope_segment.global_position = next_pinjoint.global_position
	rope_segments.insert(0, rope_segment)
	
	# update the starting pin joint and starting rope segment
	initial_joint.node_b = rope_segment.get_node("Bone-0").get_path()
	
	# update the next joint with the new rope segment and the previous in the array
	next_pinjoint.node_a = rope_segments[0].get_node("Bone-3").get_path() # guaranteed to exist
	next_pinjoint.node_b = rope_segments[1].get_node("Bone-0").get_path()
	rope_segments[0].apply_impulse(rope_segments[1].get_node("Bone-0").linear_velocity, rope_segments[1].global_position)
	next_pinjoint.bias = 0.9
	
	debug_segments += 1
	print("Created new rope segment ", debug_segments)
	
## Process physics on the yarn. When this method is called, a new segment of
## string should be attached to a the yarn.
func _physics_process(delta: float) -> void:
	# PinJoint follows behind the yarn based on the velocity
	# editors note: Turns out we don't really even need to do this anyway.
	#var interp_location = yarn_body_component.linear_velocity.normalized()
	#var interp_angle = lerp_angle(joint_parent.rotation, interp_location.angle() - PI/2, 0.5)
	#joint.rotation = interp_angle
	#joint.global_position = global_position
	#
	#velocity_dir.rotation = linear_velocity.normalized().angle()
	#velocity_dir.global_position = global_position
	
	# todo:: The math here is not exactly what I'm looking for, the segments are
	#        too small / there are not enough segments being created for how fast
	#        the ball is rolling
	var angle = yarn_body_component.rotation
	var arc_len = (angle - last_rotation) * 2 * PI
	var createNewSegment = (arc_len >= rope_segment_length || arc_len <= -rope_segment_length)

	if createNewSegment:
		# add a new segment to the rope
		last_rotation = yarn_body_component.rotation
		create_new_rope_segment()
		# todo:: make the rope smaller with more yarn segments?
	
