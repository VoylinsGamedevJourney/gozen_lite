class_name Draggable extends Node

enum { EMPTY, FILE, CLIP }

@export var type: int = EMPTY



func _get_drag_data(_position: Vector2i):
	var l_data: Array = [FILE, name]
	#set_drag_preview(make_preview(mydata)) # This is your custom method generating the preview of the drag data.
	return l_data

