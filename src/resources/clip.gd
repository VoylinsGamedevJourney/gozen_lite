class_name Clip extends PanelContainer

static var selected_clips: Array[PanelContainer] = []

var clip_id: int = -1

var is_moving: bool = false
var is_resizing_left: bool = false
var is_resizing_right: bool = false

var original_pos: float = 0.
var mouse_offset: float = 0.

var is_dragging: bool = false



func _process(_delta: float) -> void:
	if is_moving:
		pass
	elif is_resizing_left:
		# TODO: Remember that we need to change Project.tracks[track_id][start_time]
		# We could possibly do this with move_clip and just change the duration before that
		# For video clips we need to change the start time in clip_data
		pass
	elif is_resizing_right:
		pass


func set_clip_properties(a_clip_id: int) -> void:
	clip_id = a_clip_id
	set_label_text(Project.file_data[Project.clips[a_clip_id].file_id].nickname)
	position.x = Project.clips[a_clip_id].timeline_start
	size.x = Project.clips[a_clip_id].duration * Project.timeline_scale
	size.y = size.y


func set_label_text(a_text: String) -> void:
	$MarginContainer/NameLabel.text = a_text


func get_track_id() -> int:
	return get_parent().get_index()


func _on_button_pressed() -> void:
	# TODO: Check if control is pressed, else append to selected clips
	selected_clips = [self]
	# TODO: Send data to Effects panel to show the effects settings for this clip
	print("YEY")


func _on_button_button_down():
	# TODO: Start detecting if being moved or not
	get_viewport().set_input_as_handled()
	pass # Replace with function body.


func _on_button_button_up():
	# TODO: If moved in valid position, finish the move
	pass # Replace with function body.


func _get_drag_data(_position: Vector2) -> Variant:
	is_dragging = true
	Timeline.is_clip_being_moved = true
	modulate = Color(1, 1, 1, 0.1)
	return ["CLIP", clip_id, self]


func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if is_dragging:
				is_dragging = false
				Timeline.is_clip_being_moved = false
				modulate = Color(1, 1, 1, 1)
