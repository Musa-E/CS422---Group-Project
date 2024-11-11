extends StaticBody2D

@export var speed: float = 100.0  # Speed of the platform

@onready var waypoint1_position = $Waypoint1.global_position
@onready var waypoint2_position = $Waypoint2.global_position

var target_position: Vector2  # Current target position
var moving_to_waypoint1: bool = true  # Direction flag

func _ready():
	# Set the initial target position to the closest waypoint
	if global_position.distance_to(waypoint1_position) < global_position.distance_to(waypoint2_position):
		target_position = waypoint1_position
		moving_to_waypoint1 = false
	else:
		target_position = waypoint2_position
		moving_to_waypoint1 = true

func _process(delta):
	# Move the platform toward the target position
	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta

	# Check if we’ve reached the target position
	if global_position.distance_to(target_position) < speed * delta:
		# Toggle the target position without changing the waypoints
		moving_to_waypoint1 = not moving_to_waypoint1
		target_position = waypoint1_position if moving_to_waypoint1 else waypoint2_position
