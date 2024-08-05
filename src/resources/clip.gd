extends PanelContainer


var clip_id: int = -1

var is_moving: bool = false
var is_resizing_left: bool = false
var is_resizing_right: bool = false

var original_pos: float = 0.
var mouse_offset: float = 0.


func _process(_delta: float) -> void:
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


func _on_button_pressed() -> void:
	# TODO: Send data to Effects panel to show the effects settings for this clip
	print("YEY")


func _on_button_button_down():
	# TODO: Start detecting if being moved or not
	pass # Replace with function body.


func _on_button_button_up():
	# TODO: If moved in valid position, finish the move
	pass # Replace with function body.



