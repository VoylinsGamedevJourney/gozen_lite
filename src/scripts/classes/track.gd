class_name Track extends Panel

# TODO: Set size of a frame in pixels so placing clips is accurate 
# TODO: Track scaling when scale signal has been emitted.


var snap_limit: int = 20:
	get: return roundi(snap_limit * Timeline.timeline_scale)
var preview: PanelContainer = null

var _track_range: PackedInt64Array = []


func _ready() -> void:
	Timeline.instance._scale_changed.connect(adjust_scaling)	
	mouse_exited.connect(remove_preview)

	# Creating preview panel
	preview = preload("res://resources/clip_preview.tscn").instantiate()
	preview.visible = false
	preview.size.y = size.y
	add_child(preview)


func load_project() -> void:
	for l_clip_timestamp: int in Project.tracks[get_index()]:
		add_new_clip(Project.tracks[get_index()][l_clip_timestamp])


func add_clip_timedata(a_clip: ClipData) -> void:
	_track_range.append_array(range(
		a_clip.timeline_start, a_clip.timeline_start + a_clip.duration))
	


func adjust_scaling() -> void: 
	for l_clip: PanelContainer in get_children():
		if not l_clip.name.begins_with('_'): # Preview container
			l_clip.size.x = Project.clips[l_clip.name.to_int()].duration * Timeline.timeline_scale
			l_clip.position.x = Project.clips[l_clip.name.to_int()].timeline_start * Timeline.timeline_scale


func _can_drop_data(a_position: Vector2, a_data: Variant, a_video_extra: bool = false) -> bool:
	if typeof(a_data) == TYPE_INT:
		var l_type: int = Project.file_data[a_data].type
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
		if l_type == File.VIDEO:
			preview.size.x = l_duration / Project._file_data[a_data][0].get_framerate() * Project.frame_rate * Timeline.timeline_scale
		elif l_type == File.AUDIO:
			preview.size.x = l_duration * Project.frame_rate * Timeline.timeline_scale
		else:
			preview.size.x = l_duration * Timeline.timeline_scale
		set_preview(a_position.x + l_offset)
		return true
	remove_preview()
	return false


func _to_fit_or_not_to_fit(a_range: Array) -> bool: # returns spaces of adjustment needed if to fit
	for l_range_i: int in a_range:
		if l_range_i in _track_range: #Project._track_data[get_index()]:
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
		var l_clip: ClipData = ClipData.new()
		l_clip.file_id = a_data
		l_clip.timeline_start = preview.position.x 
		l_clip.duration = Project.file_data[l_clip.file_id].duration
		add_new_clip(Project.add_clip(l_clip, get_index()))


func add_new_clip(a_clip_id: int) -> void:
	var l_clip: PanelContainer = preload("res://resources/clip.tscn").instantiate()
	l_clip.set_clip_properties(a_clip_id)
	l_clip.position.x = Project.clips[a_clip_id].timeline_start
	l_clip.size.x = preview.size.x
	l_clip.size.y = size.y
	l_clip.mouse_filter = Control.MOUSE_FILTER_PASS

	add_child(l_clip)
	l_clip.name = str(a_clip_id)
	add_clip_timedata(Project.clips[a_clip_id])

