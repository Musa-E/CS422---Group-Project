extends CharacterBody2D

# todo:: convert character controller to a rigidbody for better interaction with yarn & rope physics.

# export so we can toy around with these values later.
@export var SPEED = 300.0
@export var ACCELERATION = 50.0
@export var CLIMB_SPEED = 4.0
@export var JUMP_VELOCITY = -400.0
@export var IMPULSE_MULTIPLIER = 10.0

@export var swipe_component: Area2D
@export var animations: AnimationPlayer

enum State {
	IDLE,
	MOVING,
	JUMPING,
	ATTACHED
}

var can_attach: bool = false
var current_state = State.IDLE
var path: Path2D = null

var attached_rope_segments = {}

func handle_input(delta: float) -> Vector2:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var jump := 1 if Input.is_action_just_pressed("ui_accept") else 0
	
	# update the direction of the swipe
	if direction < 0: swipe_component.scale.x = -1
	if direction > 0: swipe_component.scale.x = 1
	
	return Vector2(direction, jump)
	
#func handle_state(delta: float, current: State, input: Vector2) -> State:
	#return State.IDLE
	
func normal_movement(delta: float, input: Vector2) -> void:
	# let the player interact with the ground.
	collision_mask = 1
	
	# todo:: This does not work with the existing way the player moves, 
	#        x velocity is set after the velocity is set after detatching
	#        from the rope. We should be adding the velocities and damping
	if current_state == State.ATTACHED:
		# set the velocity of the player to keep momentum from the rope
		if len(attached_rope_segments) > 0:
			velocity = attached_rope_segments.keys()[0].linear_velocity
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if input.y != 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY

	velocity.x = input.x * SPEED if input.x else move_toward(velocity.x, 0, ACCELERATION)
	current_state = State.MOVING if velocity.x != 0 else State.IDLE
	#print(velocity)
	move_and_slide()
	
# code for when the player is attached to a rope. We should apply forces instead
# of modifying the velocity directly.
# this code is a giga nightmare of coupling help
func attached_movement(delta: float, input: Vector2) -> void:
	velocity = Vector2.ZERO
	collision_mask = 0
	if not path:
		return
		
	# Bad coupling here - Wesley
	var curve: Curve2D = path.curve
	var path_follow: PathFollow2D = path.get_child(0)
	var closest_offset = curve.get_closest_offset(path.to_local(global_position))
	
	# temporary
	var direction := Input.get_axis("ui_up", "ui_down")
	var impulse = Vector2.RIGHT * IMPULSE_MULTIPLIER * input.x
	
	# apply an impulse based on the movement direction to all nearby segments
	for segment in attached_rope_segments:
		segment.apply_central_force(impulse)
	
	# if we just latched onto the rope, find the closest offset on the path
	if current_state != State.ATTACHED:
		path_follow.progress = closest_offset
		
	path_follow.progress = lerp(path_follow.progress, path_follow.progress + direction * CLIMB_SPEED, 0.5)
	# update the player position to be the global position of the pathfollow2D after all transformations
	global_position = global_position.lerp(path_follow.global_position, 0.5)
	current_state = State.ATTACHED
	
# todo:: Add swipe ability
func swipe(delta: float, input: Vector2) -> void:
	# play animation that activates a hitbox
	pass

func _physics_process(delta: float) -> void:
	var input := handle_input(delta)
	#var next_state := update_state(delta, current_state, input)
	if can_attach and Input.is_action_pressed("grab"):
		attached_movement(delta, input)
	else:
		normal_movement(delta, input)
		if Input.is_action_just_pressed("swipe"):
			swipe(delta, input)

# Area component can only collide with the rope produced by the yarn.
func _on_check_rope_touch_body_entered(body: Node2D) -> void:
	attached_rope_segments[body] = null # add the rope segment so we can apply forces later.
	if current_state == State.ATTACHED:
		return
	can_attach = true
	# I am aware this is ugly - Wesley
	var yarn_root = body.get_node("../../..")
	path = yarn_root.rope_path

# Area component can only collide with the rope produced by the yarn.
func _on_check_rope_touch_body_exited(body: Node2D) -> void:
	attached_rope_segments.erase(body) # remove the rope segment so we don't accidentally apply forces to it.
	#print(attached_rope_segments)
	if len(attached_rope_segments) < 1:
		can_attach = false
		
@onready var camera = $Camera2D  # Reference to the Camera2D node

func _ready():
	camera.make_current()  # This sets this Camera2D as the active camera
