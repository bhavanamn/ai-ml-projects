extends Node3D

var arena01_script = load("res://Arena01/arena01.gd")

func _ready() -> void:
	var camera = Camera3D.new()
	camera.transform.origin = Vector3(0, 5, 2)  
	camera.look_at(Vector3(0, 1.5, 0))
	#camera.rotate(Vector3(0,1,0),deg_to_rad(180))
	add_child(camera)

	var a1_obj = arena01_script.new()
	a1_obj._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
