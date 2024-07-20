extends PanelContainer


var clip_id: int = -1

var is_moving: bool = false
var is_resizing_left: bool = false
var is_resizing_right: bool = false

var original_pos: float = 0.
var mouse_offset: float = 0.


func _process(a_delta: float) -> void:
	if is_moving:
		pass
	elif is_resizing_left:
		pass
	elif is_resizing_right:
		pass


func set_clip_properties(a_clip_id: int) -> void:
	clip_id = a_clip_id
	set_label_text(Project.file_data[Project.clips[a_clip_id].file_id].nickname)
	position.x = Project.clips[a_clip_id].timeline_start
	size.x = Project.clips[a_clip_id].duration * Timeline.timeline_scale
	size.y = size.y


func set_label_text(a_text: String) -> void:
	$MarginContainer/NameLabel.text = a_text


func _on_parent_resized() -> void:
	size.y = get_parent().size.y	


func _on_resized():
	$ButtonHBox/ResizeRightButton.visible = size.x < 30
	$ButtonHBox/ResizeLeftButton.visible = size.x < 30


func _on_resize_right_button_button_up() -> void:
	is_resizing_right = false


func _on_resize_right_button_button_down() -> void:
	mouse_offset = get_local_mouse_position().x
	original_pos = position.x
	is_resizing_right = true


func _on_move_button_button_up() -> void:
	is_moving = false


func _on_move_button_button_down() -> void:
	# DON't do this but use build in drag drop and change track stuff
	mouse_offset = get_local_mouse_position().x
	original_pos = position.x
	is_moving = true


func _on_resize_left_button_button_up() -> void:
	is_resizing_left = false
	# TODO: Apply changes in timedata in track, clip vars, ...


func _on_resize_left_button_button_down() -> void:
	mouse_offset = get_local_mouse_position().x
	original_pos = position.x
	is_resizing_left = false

