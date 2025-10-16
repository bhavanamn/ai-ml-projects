#extends Node3D

## Called when the node enters the scene tree for the first time.
#func _ready():	
	#print('Not supposed to be here')


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float):	
	#print('Not supposed to be here')

#
static func testprint():	
	return 'static func return test'


func testprint2():	
	return 'regular func return test'
	
