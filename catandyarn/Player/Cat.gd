extends CharacterBody2D

# todo:: convert character controller to a rigidbody for better interaction with yarn & rope

# export so we can toy around with these values later.
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

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
	collision_mask = 1
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if input.y != 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY

	velocity.x = input.x * SPEED if input.x else move_toward(velocity.x, 0, SPEED)
	current_state = State.MOVING if velocity.x != 0 else State.IDLE
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
	var closest_point = curve.get_closest_point(path.to_local(global_position))
	var closest_offset = curve.get_closest_offset(path.to_local(global_position))
	#var closest
	print(closest_point)
	
	#if current_state != State.ATTACHED:
	global_position = global_position.lerp(closest_point, 0.5)
	
	#var force_dir := Input.get_axis("ui_left", "ui_right")
	## we should update the velocity so the cat is moving to the 
	## next bone on the rope
	#path_follow.progress = lerp(closest_offset, closest_offset + input.x, 0.5)
	##print(path_follow.h_offset)
	## update the player position to be the global position of the pathfollow2D
	#global_position = global_position.lerp(path_follow.global_position, 0.5)
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
	attached_rope_segments[body.name] = body # add the rope segment so we can apply forces later.
	if current_state == State.ATTACHED:
		return
	can_attach = true
	# I am aware this is ugly - Wesley
	var yarn_root = body.get_node("../../..")
	path = yarn_root.rope_path

# Area component can only collide with the rope produced by the yarn.
func _on_check_rope_touch_body_exited(body: Node2D) -> void:
	attached_rope_segments.erase(body.name) # remove the rope segment so we don't accidentally apply forces to it.
	if len(attached_rope_segments) < 1:
		print("Stop allow attach")
		#can_attach = false
