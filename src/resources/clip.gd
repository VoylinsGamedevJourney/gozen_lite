class_name Clip extends PanelContainer

const RESIZE_HANDLE_SIZE: int = 10

static var selected_clips: Array[PanelContainer] = []

var clip_id: int = -1

var is_resizing_left: bool = false
var is_resizing_right: bool = false

var original_pos: float = 0.
var mouse_offset: float = 0.

var is_dragging: bool = false



func _process(_delta: float) -> void:
	if is_resizing_right:
		Project._is_resizing_clip.emit(clip_id, get_track_id(), false)
	elif is_resizing_left:
		Project._is_resizing_clip.emit(clip_id, get_track_id(), true)


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
	# TODO: Send data to Effects panel to show the effects settings for this clip
	# TODO: Check if control is pressed, else append to selected clips
	selected_clips = [self]


func _on_button_button_down():
	if get_local_mouse_position().x > size.x - RESIZE_HANDLE_SIZE:
		is_resizing_right = true
	elif get_local_mouse_position().x < RESIZE_HANDLE_SIZE:
		is_resizing_left = true
	else:
		is_dragging = true
	get_viewport().set_input_as_handled() # To disable playhead from moving


func _on_button_button_up():
	# TODO: Check if resizing was true for any and save changes
	is_resizing_right = false
	is_resizing_left = false


func _get_drag_data(_position: Vector2) -> Variant:
	if is_dragging:
		Timeline.is_clip_being_moved = true
		modulate = Color(1, 1, 1, 0.1)
		return ["CLIP", clip_id, self, get_local_mouse_position().x]
	return null


func _notification(notification_type):
	match notification_type:
		NOTIFICATION_DRAG_END:
			if is_dragging:
				is_dragging = false
				Timeline.is_clip_being_moved = false
				modulate = Color(1, 1, 1, 1)


func _on_resized():
	$MarginContainer.visible = size.x > 10

