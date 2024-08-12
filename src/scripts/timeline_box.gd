extends Control


var snap_limit: float = 20:
	get: return Project.frame_to_pos(snap_limit)
var preview: PanelContainer = null



func _ready() -> void:
	Project._is_resizing_clip.connect(resizing_clip)
	Project._on_timeline_scale_changed.connect(adjust_scaling)	

	mouse_exited.connect(func()->void: preview.visible = false)

	# Creating preview clip
	preview = preload("res://resources/clip_preview.tscn").instantiate()
	preview.visible = false
	preview.size.y = Project.track_size
	add_child(preview)


#------------------------------------------------ DROP HANDLING FUNCTIONS
func _can_drop_data(a_position: Vector2, a_data: Variant) -> bool:
	var l_duration: int = -1
	var l_offset: int = -100
	
	if Project.get_track_id(a_position.y) > Project.tracks.size() - 1:
		preview.visible = false
		return false

	if typeof(a_data) == TYPE_INT:
		l_duration = Project.file_data[a_data].duration	
		preview.size.x = Project.frame_to_pos(l_duration)

		if Project.pos_to_frame(a_position.x) - (float(Project.pos_to_frame(l_duration)) / 2) < -snap_limit:
			if _to_fit_or_not_to_fit(
					Project.get_track_id(a_position.y), range(Project.pos_to_frame(l_duration))):
				preview.size.x = Project.frame_to_pos(l_duration)
				set_preview(Vector2(0, a_position.y))
				return true
			else:
				return false
		else:
			for l_snap_offset: int in snap_limit:
				if _to_fit_or_not_to_fit(
						Project.get_track_id(a_position.y),
						range(
							Project.pos_to_frame(a_position.x - preview.size.x / 2) + l_snap_offset,
							Project.pos_to_frame(a_position.x - preview.size.x / 2) + l_duration + l_snap_offset)):
					l_offset = l_snap_offset
					break
				if _to_fit_or_not_to_fit(
						Project.get_track_id(a_position.y),
						range(
							Project.pos_to_frame(a_position.x - preview.size.x / 2) - l_snap_offset,
							Project.pos_to_frame(a_position.x - preview.size.x / 2) + l_duration - l_snap_offset)):
					l_offset = -l_snap_offset
					break
			if l_offset == -100:
				preview.visible = false
				return false
	elif a_data[0] == "CLIP":
		l_duration = Project.clips[a_data[1]].duration
		preview.size.x = Project.frame_to_pos(l_duration)

		var l_clip: ClipData = Project.clips[a_data[1]]

		for l_snap_offset: int in snap_limit:
			if _to_fit_or_not_to_fit(
					Project.get_track_id(a_position.y),
					range(
						Project.pos_to_frame(a_position.x - a_data[3]) + l_snap_offset,
						Project.pos_to_frame(a_position.x - a_data[3]) + l_duration + l_snap_offset),
					range(l_clip.pts, l_clip.pts + l_clip.duration),
					Project.get_track_id_from_clip(l_clip.id)):
				l_offset = l_snap_offset
				break
			if _to_fit_or_not_to_fit(
					Project.get_track_id(a_position.y),
					range(
						Project.pos_to_frame(a_position.x - a_data[3]) - l_snap_offset, 
						Project.pos_to_frame(a_position.x - a_data[3]) + l_duration - l_snap_offset)):
				l_offset = -l_snap_offset
				break
		if l_offset == -100:
			preview.visible = false
			return false
	else:
		preview.visible = false
		return false

	preview.size.x = Project.frame_to_pos(l_duration)

	if typeof(a_data) == TYPE_INT:
		set_preview(Vector2(a_position.x - preview.size.x / 2 + Project.frame_to_pos(l_offset), a_position.y))
	else:
		set_preview(Vector2(a_position.x - a_data[3] + Project.frame_to_pos(l_offset), a_position.y))

	return true


func _drop_data(_position: Vector2, a_data: Variant) -> void:
	preview.visible = false

	if typeof(a_data) == TYPE_INT:
		add_new_clip(Project.add_clip(a_data, preview.position))
	else: # Array ["CLIP", clip id, clip object, mouse offset]
		Project.move_clip(a_data[1], preview.position)
		a_data[2].queue_free()
		add_new_clip(a_data[1])

	Project._set_frame_forced.emit()


#------------------------------------------------ CLIP HANDLING FUNCTIONS
func _to_fit_or_not_to_fit(a_track: int, a_range: Array, a_excluded_range: Array = [], a_excluded_track: int = -1) -> bool: # returns spaces of adjustment needed if to fit
	for l_range_i: int in a_range:
		if l_range_i < 0:
			return false

		if l_range_i in Project._track_data[a_track]:
			if a_track == a_excluded_track and l_range_i in a_excluded_range:
				break
			return false
	return true


func set_preview(a_position: Vector2) -> void:
	var l_track_pos: float = Project.get_track_id(a_position.y)
	preview.position.y = l_track_pos * Project.track_size
	preview.position.x = Project.frame_to_pos(Project.pos_to_frame(a_position.x))

	if preview.position.x < 0:
		preview.position.x = 0

	preview.visible = true


func add_new_clip(a_clip_id: int) -> void:
	var l_clip: PanelContainer = preload("res://resources/clip.tscn").instantiate()
	l_clip.set_clip_properties(a_clip_id)
	l_clip.position.x = Project.frame_to_pos(Project.clips[a_clip_id].pts)
	l_clip.position.y = Project.track_pos_from_id(Project.get_track_id(preview.position.y))
	l_clip.size.x = preview.size.x
	l_clip.size.y = size.y
	l_clip.mouse_filter = Control.MOUSE_FILTER_PASS

	add_child(l_clip)
	Project._clip_nodes[a_clip_id] = l_clip
	l_clip.name = str(a_clip_id)



func resizing_clip(a_clip_id: int, a_left: bool) -> void:
	var l_type: int = Project.file_data[Project.clips[a_clip_id].file_id].type
	var l_clip: ClipData = Project.clips[a_clip_id]

	if a_left:
		var l_duration: int = l_clip.duration + (l_clip.pts - Project.pos_to_frame(get_local_mouse_position().x))

		if l_type in [File.AUDIO, File.VIDEO]:
			if l_duration > Project.file_data[l_clip.file_id].duration:
				return

		if l_duration < 1:
			return

		if !_to_fit_or_not_to_fit(
				Project.get_track_id_from_clip(a_clip_id),
				range(
					Project.pos_to_frame(get_local_mouse_position().x),
					Project.pos_to_frame(get_local_mouse_position().x) + l_duration),
				range(l_clip.pts, l_clip.pts + l_clip.duration),
				Project.get_track_id_from_clip(a_clip_id)):
			return

		if !_to_fit_or_not_to_fit(
				Project.get_track_id_from_clip(a_clip_id),
				range(
					Project.pos_to_frame(get_local_mouse_position().x), 
					Project.pos_to_frame(get_local_mouse_position().x) + l_duration),
				range(l_clip.pts, l_clip.pts + l_clip.duration),
				Project.get_track_id_from_clip(a_clip_id)):
			return

		Project._clip_nodes[a_clip_id].position.x = Project.frame_to_pos(l_clip.pts - (l_clip.pts - Project.pos_to_frame(get_local_mouse_position().x)))
		Project._clip_nodes[a_clip_id].size.x = Project.frame_to_pos(l_duration)
		await get_tree().process_frame
	else:
		var l_duration: int = Project.pos_to_frame(get_local_mouse_position().x) - l_clip.pts

		if l_type in [File.VIDEO, File.AUDIO]:
			if l_duration > Project.file_data[l_clip.file_id].duration:
				return

		if l_duration < 1:
			return

		if !_to_fit_or_not_to_fit(
				Project.get_track_id_from_clip(a_clip_id),
				range(
					Project.pos_to_frame(get_local_mouse_position().x),
					Project.pos_to_frame(get_local_mouse_position().x) + l_duration),
				range(l_clip.pts, l_clip.pts + l_clip.duration),
				Project.get_track_id_from_clip(a_clip_id)):
			return

		if !_to_fit_or_not_to_fit(
				Project.get_track_id_from_clip(a_clip_id),
				range(
					Project.pos_to_frame(get_local_mouse_position().x), 
					Project.pos_to_frame(get_local_mouse_position().x) + l_duration),
				range(l_clip.pts, l_clip.pts + l_clip.duration),
				Project.get_track_id_from_clip(a_clip_id)):
			return

		Project._clip_nodes[a_clip_id].size.x = Project.frame_to_pos(l_duration)


func reset_clip(a_clip_id: int) -> void:
	Project._clip_nodes[a_clip_id].position.x = Project.frame_to_pos(Project.clips[a_clip_id].pts)
	Project._clip_nodes[a_clip_id].size.x = Project.frame_to_pos(Project.clips[a_clip_id].duration)



func adjust_scaling() -> void: 
	for l_clip_id: int in Project._clip_nodes:
		Project._clip_nodes[l_clip_id].size.x = Project.clips[l_clip_id].duration * Project.timeline_scale
		Project._clip_nodes[l_clip_id].position.x = Project.frame_to_pos(Project.clips[l_clip_id].pts)
