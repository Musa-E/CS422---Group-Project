extends Node2D

# todo:: convert character controller to a rigidbody for better interaction with yarn & rope physics.

# export so we can toy around with these values later.
@export var SPEED = 300.0
@export var ACCELERATION = 50.0
@export var CLIMB_SPEED = 4.0
@export var JUMP_VELOCITY = -400.0
@export var IMPULSE_MULTIPLIER = 10.0
@export var CAMERA_FOLLOW_OFFSET_X = 125.0
@export var CAMERA_FOLLOW_OFFSET_Y = 75.0
@export var SWIPE_FORCE = 500.0

@export var swipe_component: Area2D
@export var animations: AnimationPlayer
@export var camera: Camera2D
@export var character_body: CharacterBody2D
@export var camera_follow_point: Node2D
@export var cam_follow_stack: Array = []
@export var can_swipe: bool = true
@export var sprite: Sprite2D
@onready var swipe_starting_pos = swipe_component.position

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

func _ready():
	$AnimationPlayer.play("forward_idle")

func handle_input(delta: float) -> Vector2:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	var jump := 1 if Input.is_action_just_pressed("ui_accept") else 0
	
	# update the direction of the swipe
	if direction < 0: 
		swipe_component.position.x = swipe_starting_pos.x * -1
		sprite.scale = Vector2(-5.04, sprite.scale.y)
		$AnimationPlayer.play("walk_right")
		
	if direction > 0: 
		swipe_component.position.x = swipe_starting_pos.x * 1
		sprite.scale = Vector2(5.04, sprite.scale.y)
		$AnimationPlayer.play("walk_right")
	
	if current_state == State.IDLE:
		$AnimationPlayer.play("forward_idle")
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://tutorial.tscn")
	
	return Vector2(direction, jump)
	
# updates the position of the marker that the camera follows.
func update_camera_follow_point(delta: float, input: Vector2) -> Vector2:
	if cam_follow_stack.size() < 1:
		var x = character_body.global_position.x + (CAMERA_FOLLOW_OFFSET_X * input.x)
		var y = character_body.global_position.y - (CAMERA_FOLLOW_OFFSET_Y)
		camera_follow_point.global_position = camera_follow_point.global_position.lerp(Vector2(x, y), 0.3)
		return Vector2(x, y)
	camera_follow_point.global_position = camera_follow_point.global_position.lerp(cam_follow_stack[-1].global_position, 0.3)
	return cam_follow_stack[-1].global_position
	
func normal_movement(delta: float, input: Vector2) -> void:
	# let the player interact with the ground.
	character_body.collision_mask = 1
	
	# todo:: This does not work with the existing way the player moves, 
	#        x velocity is set after the velocity is set after detatching
	#        from the rope. We should be adding the velocities and damping
	if current_state == State.ATTACHED:
		# set the velocity of the player to keep momentum from the rope
		if len(attached_rope_segments) > 0:
			character_body.velocity = attached_rope_segments.keys()[0].linear_velocity
	
	# Add the gravity.
	if not character_body.is_on_floor():
		character_body.velocity += character_body.get_gravity() * delta

	# Handle jump.
	if input.y != 0 and character_body.is_on_floor():
		character_body.velocity.y = JUMP_VELOCITY

	var accel = 1 if abs(character_body.velocity.x) > abs(input.x * SPEED) else ACCELERATION
	character_body.velocity.x = move_toward(character_body.velocity.x, input.x * SPEED, accel) if input.x else move_toward(character_body.velocity.x, 0, ACCELERATION)
	current_state = State.MOVING if character_body.velocity.x != 0 else State.IDLE
	character_body.move_and_slide()
	
# code for when the player is attached to a rope. We should apply forces instead
# of modifying the velocity directly.
# this code is a giga nightmare of coupling help
func attached_movement(delta: float, input: Vector2) -> void:
	character_body.velocity = Vector2.ZERO
	character_body.collision_mask = 0
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
	character_body.global_position = character_body.global_position.lerp(path_follow.global_position, 0.5)
	current_state = State.ATTACHED
	
# todo:: Add swipe ability
func swipe(delta: float, input: Vector2) -> void:
	# play animation that activates a hitbox
	animations.play("swipe")
	
func _process(delta: float) -> void:
	var input := handle_input(delta)
	# update camera position
	camera.global_position = camera.global_position.lerp(update_camera_follow_point(delta, input), 0.025)

func _physics_process(delta: float) -> void:
	var input := handle_input(delta)
	#var next_state := update_state(delta, current_state, input)
	if can_attach and Input.is_action_pressed("grab"):
		attached_movement(delta, input)
	else:
		normal_movement(delta, input)
		if Input.is_action_just_pressed("swipe") and can_swipe:
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
		
func _on_check_cam_follow_area_entered(area: Area2D) -> void:
	cam_follow_stack.append(area)
	# adjust the camera zoom
	var collider: CollisionShape2D = area.get_child(0) # we assume has 1 child that's a collision shape???
	var shape: RectangleShape2D = collider.shape
	var zoom_level_x = min(1,  get_viewport().size.x / shape.size.x)
	var zoom_level_y = min(1, get_viewport().size.y / shape.size.y)
	var zoom = min(zoom_level_x, zoom_level_y)
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(zoom, zoom), 0.5)
	tween.play()
	
func _on_check_cam_follow_area_exited(area: Area2D) -> void:
	cam_follow_stack.resize(cam_follow_stack.size() - 1)
	# adjust the zoom size
	var zoom = 1
	if cam_follow_stack.size() > 0:
		var collider: CollisionShape2D = cam_follow_stack[-1].get_child(0) # we assume has 1 child that's a collision shape???
		var shape: RectangleShape2D = collider.shape
		var zoom_level_x = min(1,  get_viewport().size.x / shape.size.x)
		var zoom_level_y = min(1, get_viewport().size.y / shape.size.y)
		zoom = min(zoom_level_x, zoom_level_y)
	var tween = create_tween()
	tween.tween_property(camera, "zoom", Vector2(zoom, zoom), 0.5)
	tween.play()

func _on_swipe_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		var yarn: RigidBody2D = body
		var force = (yarn.global_position - swipe_component.global_position) * SWIPE_FORCE
		yarn.apply_central_impulse(force)
		
