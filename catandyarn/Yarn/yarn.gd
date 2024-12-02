extends Node2D

## The scene for each rope segment.
@export var rope_segment_scene: PackedScene = null
## Flag that enables or disables yarn rope growth. Set to true once the max number of segments is reached if max_segments > -1.
@export var allow_expanding_yarn: bool = false
## Controls how far the player can climb up the yarn rope.
@export var skip_n_segments_for_path = 0
## Creates n instances of rope segments when the scene is instanced.
@export var on_start_segments: int = 1
## Controls how often rope segments are created.
@export var rope_segment_length: float
## The mass of the yarn.
@export var yarn_mass: float = 2
## The maximum number of segments for the rope to create. Set to -1 for unlimited amount of segments.
@export var max_segments: int = -1
@export var joint_parent: Node2D
@export var rope_path: Path2D
## Flag for printing debug statements.
@export var use_debug = true
## Flag for printing the climb lines for the yarn ropes.
@export var debug_line_draw: MeshInstance2D
@onready var initial_rope_segment: SoftBody2D = $"Joint/SoftBody2D"
@onready var initial_joint: PinJoint2D = $"Joint/PinJoint2D"
@onready var rope_segments: Array[SoftBody2D] = []
@onready var debug_segments: int = 0
@onready var yarn_body_component: RigidBody2D = $"Yarn"

var last_rotation = 0

func _ready() -> void:
	 #set initial rope segment
	rope_segments.append(initial_rope_segment)
	initial_joint.node_a = yarn_body_component.get_path() # we are on the yarn
	initial_joint.node_b = initial_rope_segment.get_node("Bone-0").get_path()
	
	yarn_body_component.mass = yarn_mass
	
	for n in range(1, on_start_segments):
		create_new_rope_segment()

func create_new_rope_segment() -> void:
	# define the new box
	var rope_segment := rope_segment_scene.instantiate()
	var next_pinjoint := PinJoint2D.new()
	joint_parent.call_deferred("add_child", next_pinjoint)
	joint_parent.call_deferred("add_child", rope_segment)
	await rope_segment.ready
	rope_segments.append(rope_segment)
	next_pinjoint.global_position = rope_segments[-2].get_node("Bone-3").global_position
	rope_segment.global_position = next_pinjoint.global_position
	next_pinjoint.node_a = rope_segments[-2].get_node("Bone-3").get_path() # guaranteed to exist
	next_pinjoint.node_b = rope_segments[-1].get_node("Bone-0").get_path()
	rope_segments[-1].apply_impulse(rope_segments[-2].get_node("Bone-3").linear_velocity, rope_segments[-2].global_position)
	next_pinjoint.bias = 0.9
	
	debug_segments += 1
	if debug_segments >= max_segments and max_segments > -1:
		allow_expanding_yarn = false
		
	if use_debug:
		print("Created new rope segment ", debug_segments)
	
func create_new_rope_segment_front() -> void:
	 #define the new box
	var rope_segment := rope_segment_scene.instantiate()
	rope_segment.show_shapes = true
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
	next_pinjoint.bias = 0.0
	
	debug_segments += 1
	
func update_rope_path() -> void:
	# get each bone in the softbody and update the points in the existing path
	# try clearing the points in the path and then rebuilding them
	var curve := rope_path.curve
	curve.clear_points()
	# yes I know this is horribly unoptimized. Luckily the array of rope points
	# will usually be relatively small (we're not talking hundreds of segments here)
	var idx = skip_n_segments_for_path
	for segment in rope_segments:
		# todo:: dumb - wesley
		if idx > 0:
			idx -= 1
			continue

		for bone in segment.get_children():
			if bone is RigidBody2D:
				var gpos: Vector2 = bone.global_position - (global_position)
				curve.add_point(gpos)

	# draw the line in game if debug is active
	if use_debug:
		var geom: ImmediateMesh = debug_line_draw.mesh
		geom.clear_surfaces()
		geom.surface_begin(Mesh.PRIMITIVE_LINES)
		for point in curve.get_baked_points():
			geom.surface_add_vertex_2d(point)
		geom.surface_end()
	
	
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

	if createNewSegment and allow_expanding_yarn:
		# add a new segment to the rope
		last_rotation = yarn_body_component.rotation
		create_new_rope_segment()
		# todo:: make the rope smaller with more yarn segments?
		
	update_rope_path()
	
