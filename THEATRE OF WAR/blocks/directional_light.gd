extends DirectionalLight3D

var energy
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	light_energy = energy if energy != null else 5
	#pass # Replace with function body.
