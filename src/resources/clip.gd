class_name Clip extends PanelContainer

const RESIZE_HANDLE_SIZE: int = 10

static var selected_clips: Array[PanelContainer] = []

var id: int = -1

var is_resizing_left: bool = false
var is_resizing_right: bool = false

var original_pos: float = 0.
var mouse_offset: float = 0.

var is_dragging: bool = false



func _ready() -> void:
	size.y = Project.track_size


func _process(_delta: float) -> void:
	if is_resizing_right:
		Project._is_resizing_clip.emit(id, false)
	elif is_resizing_left:
		Project._is_resizing_clip.emit(id, true)


func set_clip_properties(a_clip_id: int) -> void:
	id = a_clip_id
	set_label_text(Project.get_file_from_clip(id).nickname)
	position.x = Project.get_clip_data(a_clip_id).pts
	size.x = Project.clips[a_clip_id].duration * Project.timeline_scale
	size.y = size.y


func set_label_text(a_text: String) -> void:
	($MarginContainer/NameLabel as Label).text = a_text


func get_track_id() -> int:
	return Project.get_track_id(position.y)


func _on_button_pressed() -> void:
	# TODO: Send data to Effects panel to show the effects settings for this clip
	# TODO: Check if control is pressed, else append to selected clips
	selected_clips = [self]


func _on_button_button_down() -> void:
	if Input.is_key_pressed(KEY_SPACE):
		return
	if get_local_mouse_position() > size or get_local_mouse_position() < Vector2.ZERO:
		return #Mouse is not on button (incase of pressing space with button selected)
	if get_local_mouse_position().x > size.x - RESIZE_HANDLE_SIZE:
		is_resizing_right = true
	elif get_local_mouse_position().x < RESIZE_HANDLE_SIZE:
		is_resizing_left = true
	else:
		is_dragging = true
	get_viewport().set_input_as_handled() # To disable playhead from moving


func _on_button_button_up() -> void:
	if is_resizing_right or is_resizing_left:
		Project.resize_clip(id, is_resizing_left)
		is_resizing_right = false
		is_resizing_left = false


func _get_drag_data(_position: Vector2) -> Variant:
	if is_dragging:
		if is_resizing_left or is_resizing_right:
			is_resizing_right = false
			is_resizing_left = false
			(get_parent() as TimelineBox).reset_clip(id)
		Timeline.is_clip_being_moved = true
		modulate = Color(1, 1, 1, 0.1)
		return ["CLIP", id, self, get_local_mouse_position().x]
	return null


func _notification(a_notification_type: int) -> void:
	match a_notification_type:
		NOTIFICATION_DRAG_END:
			if is_dragging:
				is_dragging = false
				Timeline.is_clip_being_moved = false
				modulate = Color(1, 1, 1, 1)


func _on_resized() -> void:
	($MarginContainer as MarginContainer).visible = size.x > 10

