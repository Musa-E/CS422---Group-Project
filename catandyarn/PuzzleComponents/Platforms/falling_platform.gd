extends StaticBody2D

@onready var area = get_node("Area2D")
@onready var break_timer = get_node("Area2D/Timer")  # Timer to break the platform
@onready var reappear_timer = get_node("ReappearTimer")  # New timer to make it reappear
@onready var collision_shape = $CollisionShape2D
# Function that runs when the player lands on the platform
func _on_Area2D_body_entered(body):
	if body is CharacterBody2D:
		break_timer.start() 
		print("debug") # Start the timer to break the platform

# Function to handle the break timer timeout
func _on_Timer_timeout():
	hide()  # Hide the platform
	collision_shape.disabled = true
	reappear_timer.start()  # Start the reappear timer

# Function to handle the reappear timer timeout
func _on_ReappearTimer_timeout():
	show()  # Show the platform again
	collision_shape.disabled = false
func _ready():
	# Connect signals (remove this if you've connected them in the editor)
	area.body_entered.connect(_on_Area2D_body_entered)
	break_timer.timeout.connect(_on_Timer_timeout)
	reappear_timer.timeout.connect(_on_ReappearTimer_timeout)
