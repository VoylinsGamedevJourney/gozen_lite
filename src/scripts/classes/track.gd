class_name Track extends Control


var snap_limit: int = 50
var preview: PanelContainer = null



func _ready() -> void:
	# Creating preview panel
	preview = PanelContainer.new()
	preview.visible = false
	preview.size.y = 20
	preview.mouse_filter = Control.MOUSE_FILTER_PASS
	preview.add_theme_stylebox_override("panel", preload("res://resources/clip_preview.tres"))
	add_child(preview)
	mouse_exited.connect(remove_preview)
	

func _can_drop_data(a_position: Vector2, a_data: Variant, a_video_extra: bool = false) -> bool:
	if typeof(a_data) == TYPE_INT:
		var l_duration: int = Project.file_data[a_data].duration
		var l_offset: int = -100
		for l_snap_offset: int in snap_limit:
			if _to_fit_or_not_to_fit(range(
					a_position.x + l_snap_offset, a_position.x + l_duration + l_snap_offset)):
				l_offset = l_snap_offset
				break
			if _to_fit_or_not_to_fit(range(
					a_position.x - l_snap_offset, a_position.x + l_duration - l_snap_offset)):
				l_offset = -l_snap_offset
				break
		if l_offset == -100:
			remove_preview()
			return false
		preview.size.x = l_duration
		set_preview(a_position.x + l_offset)
		return true
	remove_preview()
	return false


func _to_fit_or_not_to_fit(a_range: Array) -> bool: # returns spaces of adjustment needed if to fit
	for l_range_i: int in a_range:
		if l_range_i in Project._track_data[get_index()]:
			return false
	return true


func set_preview(a_position: float) -> void:
	preview.position.x = a_position
	preview.visible = true


func remove_preview() -> void:
	preview.visible = false


func _drop_data(a_position: Vector2, a_data: Variant) -> void:
	remove_preview()
	if typeof(a_data) == TYPE_INT:
		var l_clip: Clip = Clip.new()
		l_clip.file_id = a_data
		l_clip.timeline_start = preview.position.x 
		l_clip.duration = Project.file_data[l_clip.file_id].duration
		add_new_clip(Project.add_clip(l_clip, get_index()))


func add_new_clip(a_clip_id: int) -> void:
	var l_clip: PanelContainer = PanelContainer.new()
	var l_label: Label = Label.new()
	l_clip.position.x = Project.clips[a_clip_id].timeline_start
	l_clip.size.y = 20
	l_clip.size.x = Project.clips[a_clip_id].duration
	l_clip.mouse_filter = Control.MOUSE_FILTER_PASS
	l_clip.add_theme_stylebox_override("panel", preload("res://resources/clip.tres"))
	l_label.text = Project.file_data[Project.clips[a_clip_id].file_id].nickname
	l_label.clip_text = true
	l_label.add_theme_font_size_override("font_size", 10)
	l_label.tooltip_text = Project.file_data[Project.clips[a_clip_id].file_id].nickname
	l_clip.add_child(l_label)
	add_child(l_clip)

