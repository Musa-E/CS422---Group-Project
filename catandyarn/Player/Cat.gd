extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

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

func handle_input(delta: float) -> Vector2:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var jump := 1 if Input.is_action_just_pressed("ui_accept") else 0
	
	# update the direction of the swipe
	if direction < 0: swipe_component.scale.x = -1
	if direction > 0: swipe_component.scale.x = 1
	
	return Vector2(direction, jump)
	
#func update_state(delta: float, current: State, input: Vector2) -> State:
	#return State.IDLE
	
func normal_movement(delta: float, input: Vector2) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if input.y != 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY

	velocity.x = input.x * SPEED if input.x else move_toward(velocity.x, 0, SPEED)
	current_state = State.MOVING
	move_and_slide()
	
# code for when the player is attached to a rope. We should apply forces instead
# of modifying the velocity directly.
func attached_movement(delta: float, input: Vector2) -> void:
	velocity = Vector2.ZERO
	# we should update the velocity so the cat is moving to the 
	# next bone on the rope
	pass
	
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
	if can_attach:
		return
	can_attach = true

# Area component can only collide with the rope produced by the yarn.
func _on_check_rope_touch_body_exited(body: Node2D) -> void:
	if not can_attach:
		return
	can_attach = false
