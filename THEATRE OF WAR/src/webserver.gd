extends Node

signal download_completed(success, x, y, offset_x, offset_y)

var current_x = 0
var current_y = 0
var offset_x = 0
var offset_y = 0

func download_file(x, y, offset_x, offset_y):
	self.current_x = x
	self.current_y = y
	self.offset_x = offset_x
	self.offset_y = offset_y
	#var http_request = HTTPRequest.new()
	#add_child(http_request)

	#var download_http = "https://tiles.streets.gl/vector/16/" + str(x) + "/" + str(y)
	var _download_local = "res://tiles/" + str(x) + str(y)
	#print(_download_local)
	#http_request.download_file = _download_local
	#print(current_x, ',', current_y, ',',offset_x, ',',offset_y)

	#http_request.request_completed.connect(_on_request_completed)
	#http_request.request(download_http)
	emit_signal("download_completed", true, x, y, offset_x, offset_y)
# parameters are required regardles of usage
# gdlint:ignore = unused-argument
func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		emit_signal("download_completed", true, current_x, current_y, offset_x, offset_y)
	else:
		emit_signal("download_completed", false, current_x, current_y, offset_x, offset_y)
