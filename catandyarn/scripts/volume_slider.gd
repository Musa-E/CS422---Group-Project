extends HSlider

@export
var bus_name: String
var bus_index: int

func _ready() -> void:
	# Get the audio bus index from its name
	bus_index = AudioServer.get_bus_index(bus_name)
	
	# Initialize the slider's value to reflect the current volume
	#value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
		# Load initial value from global_settings
	match bus_name:
		"Master":
			value = GlobalSettings.master_volume
		"Music":
			value = GlobalSettings.music_volume
		"Effects":
			value = GlobalSettings.effects_volume
	
	# Connect the value_changed signal
	value_changed.connect(_on_value_changed)

# Signal handler for when the slider value changes
func _on_value_changed(value: float) -> void:
	
	# Cast val to linear
	var db = linear_to_db(value)
	# print("Linear:", value, " -> dB:", db)
	
	AudioServer.set_bus_volume_db(bus_index, db)
	
	# Save current value to global_settings
	match bus_name:
		"Master":
			GlobalSettings.master_volume = value
		"Music":
			GlobalSettings.music_volume = value
		"Effects":
			GlobalSettings.effects_volume = value

# Convert linear (0.0 - 1.0) to dB scale (-80 to 0)
func linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0  # Prevent log10(0) issues
	return -80.0 + (value * 80.0)  # Scale 0.0 -> -80.0, 1.0 -> 0.0

# Convert dB scale (-80 to 0) back to linear (0.0 - 1.0)
func db_to_linear(db: float) -> float:
	return clamp((db + 80.0) / 80.0, 0.0, 1.0)  # Scale -80.0 -> 0.0, 0.0 -> 1.0
