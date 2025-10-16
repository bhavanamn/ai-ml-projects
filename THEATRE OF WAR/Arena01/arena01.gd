extends Node3D

var utils_script = load("res://Arena01/utils01.gd")
#var utils_script2 = load("res://Arena/utils01.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ret = utils_script.testprint()
	print(ret)
		
	var us_obj = utils_script.new()
	ret = us_obj.testprint2()
	print(ret)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
