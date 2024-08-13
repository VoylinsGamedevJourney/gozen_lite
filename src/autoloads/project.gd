extends DataManager

# TODO: When changing frame_rate, we need to re-calculate all video and audio files duration

#------------------------------------------------ SIGNALS
signal _on_project_saved
signal _on_project_loaded

signal _on_file_added(file_id: int)

signal _on_timeline_scale_changed
signal _update_timeline
signal _on_end_frame_pts_changed(end_pts: int)

signal _set_frame(frame_nr: int)
signal _set_frame_forced
signal _playhead_moved(is_moving: bool)

signal _is_resizing_clip(clip_id: int, direction_left: bool) # direction: true = left, false = right

signal _show_file_effects(file_id: int)
signal _show_clip_effects(clip_id: int)

signal _open_render_menu
signal _is_rendering(value: bool)
signal _send_frame(frame: Image)
signal _sending_frames_finished


#------------------------------------------------ TEMPORARY VARIABLES
var _path: String = ""
var _file_data: Dictionary = {}
var _track_data: Array[PackedInt64Array] = []
var _clip_nodes: Dictionary = {}

var _err: int = 0

#------------------------------------------------ DATA VARIABLES
var counter_file_id: int = 0
var counter_clip_id: int = 0

var files: Dictionary = {}
var tracks: Array[Dictionary] = [] # Inside Array are dictionaries. Key = frame number, Value = clip id
var clips: Dictionary = {} # Clip_id = Clip data

var timeline_scale: float = 1. # One frame is a pixel in this scale
var track_size: int = 36 # NOTE: Maybe move to settings later on?

var frame_rate: float = 30.
var resolution: Vector2i = Vector2i(1920, 1080)


#------------------------------------------------ GODOT FUNCTIONS
func _ready() -> void:
	for _i: int in Settings.default_tracks:
		tracks.append({})
		_track_data.append(PackedInt64Array())
	_err = get_window().files_dropped.connect(Project._on_files_dropped)
	if _err:
		printerr("Connect function failed! ", _err)


#------------------------------------------------ PROJECT DATA FUNCTIONS
func open_project(a_path: String) -> void:
	if a_path.get_extension().to_lower() == "gozen":
		load_project(a_path)
	else:
		printerr("%s is an invalid project path!" % a_path)


func save_project(a_path: String = "") -> void:
	if a_path.is_empty():
		# TODO: Move to a separate class, removed everything for mow
		return
	_path = a_path

	_err = save_data(_path)
	if _err:
		printerr("Error occurred saving file! ", _err)
	_on_project_saved.emit()


func load_project(a_path: String) -> void:
	if a_path.is_empty():
		# TODO: Move to a separate class, removed everything for mow
		return
	reset_project()

	_path = a_path
	_err = load_data(_path)
	if _err:
		printerr("Error occurred loading file!  ", _err)

	for l_file_id: int in files:
		get_file(l_file_id).add_file_data()
	for _i: int in range(tracks.size()):
		_track_data.append([])

	_on_project_loaded.emit()


func reset_project() -> void:
	_path = ""
	_file_data = {}
	counter_file_id = 0
	files = {}
	tracks = []
	counter_clip_id = 0
	clips = {}
	frame_rate = 30.


#------------------------------------------------ GETTERS AND SETTERS
func get_file(a_file_id: int) -> File:
	return files[a_file_id]


func set_file(a_file_id: int, a_file: File) -> void:
	files[a_file_id] = a_file


func get_file_from_clip(a_clip_id: int) -> File:
	return files[clips[a_clip_id].file_id]


func set_file_from_clip(a_clip_id: int, a_file: File) -> void:
	files[clips[a_clip_id].file_id] = a_file


func get_file_data(a_file_id: int) -> Variant:
	return _file_data[a_file_id]


func set_file_data(a_file_id: int, a_file_data: Variant) -> void:
	_file_data[a_file_id] = a_file_data


func get_file_data_from_clip(a_clip_id: int) -> File:
	return _file_data[clips[a_clip_id].file_id]


func set_file_data_from_clip(a_clip_id: int, a_file_data: Variant) -> void:
	_file_data[clips[a_clip_id].file_id] = a_file_data


func get_video_file_data(a_file_id: int, a_entry: int) -> VideoData:
	return _file_data[a_file_id][a_entry]


func set_video_file_data(a_file_id: int, a_entry: int, a_video_data: VideoData) -> void:
	_file_data[a_file_id][a_entry] = a_video_data


func get_video_file_data_from_clip(a_clip_id: int, a_entry: int) -> VideoData:
	return _file_data[clips[a_clip_id].file_id][a_entry]


func set_video_file_data_from_clip(a_clip_id: int, a_entry: int, a_video_data: VideoData) -> void:
	_file_data[clips[a_clip_id].file_id][a_entry] = a_video_data


func get_clip_node(a_clip_id: int) -> Clip:
	return _clip_nodes[a_clip_id]


func set_clip_node(a_clip_id: int, a_clip: Clip) -> void:
	_clip_nodes[a_clip_id] = a_clip


func get_clip_data(a_clip_id: int) -> ClipData:
	return clips[a_clip_id]


func set_clip_data(a_clip_id: int, a_clip_data: ClipData) -> void:
	clips[a_clip_id] = a_clip_data


#------------------------------------------------ FILE FUNCTIONS
func _on_files_dropped(a_files: PackedStringArray) -> void:
	for l_file_path: String in a_files:
		if !File.create_file(l_file_path):
			printerr("Something went wrong adding file: %s" % l_file_path)


#------------------------------------------------ CLIP FUNCTIONS
func add_clip(l_file_id: int, a_position: Vector2) -> int:
	counter_clip_id += 1

	clips[counter_clip_id] = ClipData.new()
	clips[counter_clip_id].id = counter_clip_id
	clips[counter_clip_id].file_id = l_file_id
	clips[counter_clip_id].pts = pos_to_frame(a_position.x)
	clips[counter_clip_id].duration = files[l_file_id].duration
	clips[counter_clip_id].frame_start = 0
	clips[counter_clip_id].frame_end = files[l_file_id].duration
	tracks[get_track_id(a_position.y)][clips[counter_clip_id].pts] = counter_clip_id

	add_clip_timedata(counter_clip_id, get_track_id(a_position.y))
	_update_timeline.emit()
	_set_frame_forced.emit()
	return counter_clip_id


func move_clip(a_clip_id: int, a_new_position: Vector2) -> void:
	var l_prev_track: int = get_track_id_from_clip(a_clip_id)
	var l_new_track: int = get_track_id(a_new_position.y)
	var l_new_pts: int = pos_to_frame(a_new_position.x)

	remove_clip_timedata(a_clip_id, l_prev_track)

	tracks[l_new_track][l_new_pts] = a_clip_id
	clips[a_clip_id].pts = l_new_pts

	add_clip_timedata(a_clip_id, l_new_track)
	_update_timeline.emit()
	_set_frame_forced.emit()


func remove_clip(a_clip_id: int) -> void:
	var l_prev_track: int = get_track_id_from_clip(a_clip_id)

	remove_clip_timedata(a_clip_id, l_prev_track)
	
	if !tracks[l_prev_track].erase(clips[a_clip_id].pts):
		printerr("Error occurred erasing entry from tracks!")
	if !clips.erase(a_clip_id):
		printerr("Error occurred erasing entry from clips!")
	if !_clip_nodes.erase(a_clip_id):
		printerr("Error occurred erasing entry from _clip_nodes!")

	_update_timeline.emit()
	_set_frame_forced.emit()


func resize_clip(a_clip_id: int, a_left: bool) -> void:
	var l_clip_node: PanelContainer = _clip_nodes[a_clip_id]
	var l_track: int = get_track_id_from_clip(a_clip_id)
	remove_clip_timedata(a_clip_id, l_track)
	
	if !tracks[l_track].erase(clips[a_clip_id].pts):
		printerr("Error occurred erasing entry from tracks!")
	clips[a_clip_id].duration = pos_to_frame(l_clip_node.size.x)
	clips[a_clip_id].pts = pos_to_frame(l_clip_node.position.x)
	tracks[l_track][clips[a_clip_id].pts] = a_clip_id

	if files[clips[a_clip_id].file_id].type in [File.AUDIO, File.VIDEO]:
		var l_difference: int = (clips[a_clip_id].frame_end - clips[a_clip_id].frame_start) - clips[a_clip_id].duration
		if a_left:
			clips[a_clip_id].frame_start += l_difference
		else:
			clips[a_clip_id].frame_end -= l_difference

	add_clip_timedata(a_clip_id, l_track)


func add_clip_timedata(a_clip_id: int, a_track: int = -1) -> void:
	for _i: int in range(tracks.size() - _track_data.size()):
		_track_data.append([])

	if a_track != -1:
		_track_data[a_track].append_array(range(
				clips[a_clip_id].pts, clips[a_clip_id].pts + clips[a_clip_id].duration))
	else:
		_track_data[get_track_id_from_clip(a_clip_id)].append_array(range(
				clips[a_clip_id].pts, clips[a_clip_id].pts + clips[a_clip_id].duration))
	_on_end_frame_pts_changed.emit(get_end_frame_pts())


func remove_clip_timedata(a_clip_id: int, a_prev_track: int) -> void:
	var l_clip_data: ClipData = clips[a_clip_id]
	if files[l_clip_data.file_id].type in [File.VIDEO, File.AUDIO]:
		for l_i: int in range(l_clip_data.pts, l_clip_data.pts + l_clip_data.duration - l_clip_data.frame_start):
			_track_data[a_prev_track].remove_at(_track_data[a_prev_track].rfind(l_i))
	else:
		for l_i: int in range(l_clip_data.pts, l_clip_data.pts + l_clip_data.duration):
			_track_data[a_prev_track].remove_at(_track_data[a_prev_track].rfind(l_i))

	_on_end_frame_pts_changed.emit(get_end_frame_pts())


#------------------------------------------------ TIMELINE FUNCTIONS
func get_track_id(a_pos_y: float) -> int:
	return floor(a_pos_y / track_size)


func get_track_id_from_clip(a_clip_id: int) -> int:
	var l_clip_node: PanelContainer = _clip_nodes[a_clip_id]
	return get_track_id(l_clip_node.position.y)


func track_pos_from_id(a_id: int) -> int:
	return a_id * track_size


func pos_to_frame(a_pos: float) -> int:
	return floor(a_pos / timeline_scale)


func frame_to_pos(a_frame_nr: int) -> float:
	return a_frame_nr * timeline_scale


func get_end_frame_pts() -> int: # Returns last viable frame of project
	var l_end_timepoint: int = 0
	var l_keys: Array

	for l_track: Dictionary in tracks:
		l_keys = l_track.keys()
		if l_keys.size() == 0 or clips.size() == 0:
			continue

		l_keys.sort()
		var l_clip_data: ClipData = clips[l_track[l_keys[-1]]]
		l_end_timepoint = maxi(
				l_end_timepoint, 
				l_clip_data.pts + l_clip_data.duration)

	return l_end_timepoint


func set_timeline_scale(a_value: float) -> void:
	timeline_scale = clampf(a_value, Settings.timeline_scale_min, Settings.timeline_scale_max)
	_on_timeline_scale_changed.emit()

