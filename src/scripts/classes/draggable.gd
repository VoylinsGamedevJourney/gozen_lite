class_name Draggable extends Node
# Will only be used for dragging files onto the timeline
# TODO: Check for when multiple files were selected to drag into the timeline


func _get_drag_data(_position: Vector2i) -> Variant:
	return name.bin_to_int()

