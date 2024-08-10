extends DataManager

# TODO: When changing frame_rate, we need to re-calculate all video and audio files duration

#------------------------------------------------ SIGNALS
signal _on_project_saved
signal _on_project_loaded

signal _on_file_added(file_id: int)

signal _on_timeline_scale_changed
signal _update_timeline

signal _set_frame(frame_nr)
signal _set_frame_forced
signal _playhead_moved(value)

signal _is_resizing_clip(clip_id, track_id, direction) # direction: true = left, false = right


#------------------------------------------------ TEMPORARY VARIABLES
var _path: String = ""
var _file_data: Dictionary = {}
var _track_data: Array[PackedInt64Array] = []
var _clip_nodes: Dictionary = {}

#------------------------------------------------ DATA VARIABLES
var counter_file_id: int = 0
var counter_clip_id: int = 0

var file_data: Dictionary = {}
var tracks: Array[Dictionary] = [] # Inside Array are dictionaries. Key = frame number, Value = clip id
var clips: Dictionary = {} # Clip_id = Clip data

var timeline_scale: float = 1. # One frame is a pixel in this scale
var track_size: int = 20 # NOTE: Maybe move to settings later on?

var frame_rate: float = 30.
var resolution: Vector2i = Vector2i(1920, 1080)


#------------------------------------------------ GODOT FUNCTIONS
func _ready() -> void:
	for _i: int in Settings.default_tracks:
		tracks.append({})
		_track_data.append(PackedInt64Array())
	get_window().files_dropped.connect(Project._on_files_dropped)


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

	save_data(_path)
	_on_project_saved.emit()


func load_project(a_path: String) -> void:
	if a_path.is_empty():
		# TODO: Move to a separate class, removed everything for mow
		return
	reset_project()

	_path = a_path
	load_data(_path)

	for l_file_id: int in file_data:
		file_data[l_file_id].add_file_data()
	for _i: int in range(tracks.size()):
		_track_data.append([])

	_on_project_loaded.emit()


func reset_project() -> void:
	_path = ""
	_file_data = {}
	counter_file_id = 0
	file_data = {}
	tracks = []
	counter_clip_id = 0
	clips = {}
	frame_rate = 30.


#------------------------------------------------ FILE FUNCTIONS
func _on_files_dropped(a_files: PackedStringArray) -> void:
	for l_file_path: String in a_files:
		File.create_file(l_file_path)


#------------------------------------------------ CLIP FUNCTIONS
func add_clip(l_file_id: int, l_start_frame: int, a_track_id: int) -> void:
	counter_clip_id += 1
	var l_id: int = counter_clip_id

	clips[l_id] = ClipData.new()
	clips[l_id].id = counter_clip_id
	clips[l_id].file_id = l_file_id
	clips[l_id].start_frame = l_start_frame
	tracks[a_track_id][clips[l_id].start_frame] = clips[l_id].id

	add_clip_timedata(clips[l_id].id)


func move_clip(a_clip_id: int, a_new_position: Vector2) -> void:
	var l_prev_track: int = get_track_id_from_clip(a_clip_id)
	var l_prev_pts: int = pos_to_frame(_clip_nodes[a_clip_id].position.x)
	var l_new_track: int = get_track_id(a_new_position.y)
	var l_new_pts: int = pos_to_frame(a_new_position.x)

	remove_clip_timedata(a_clip_id, l_prev_track)

	tracks[l_prev_track].erase(l_prev_pts)
	tracks[l_new_track][l_new_pts] = a_clip_id
	clips[a_clip_id].pts = pos_to_frame(l_new_pts)

	add_clip_timedata(a_clip_id)


func remove_clip(a_clip_id: int) -> void:
	var l_prev_track: int = get_track_id_from_clip(a_clip_id)

	remove_clip_timedata(a_clip_id, l_prev_track)

	tracks[l_prev_track].erase(clips[a_clip_id].pts)
	clips.erase(a_clip_id)


func resize_clip(a_clip_id: int, a_left: bool) -> void:
	var l_track: int = get_track_id_from_clip(a_clip_id)
	remove_clip_timedata(a_clip_id, l_track)

	if file_data[clips[a_clip_id].file_id].type in [File.AUDIO, File.VIDEO] and a_left:
		clips[a_clip_id].start_frame += clips[a_clip_id].pts - pos_to_frame(_clip_nodes[a_clip_id].position.x)

	tracks[l_track].erase(clips[a_clip_id].pts)
	clips[a_clip_id].duration = pos_to_frame(_clip_nodes[a_clip_id].size.x)
	clips[a_clip_id].pts = pos_to_frame(_clip_nodes[a_clip_id].position.x)
	tracks[l_track][clips[a_clip_id].pts] = a_clip_id

	add_clip_timedata(a_clip_id)


func add_clip_timedata(a_clip_id: int) -> void:
	for _i: int in range(tracks.size() - _track_data.size()):
		_track_data.append([])

	_track_data[get_track_id_from_clip(a_clip_id)].append_array(range(
			clips[a_clip_id].pts, clips[a_clip_id].pts + clips[a_clip_id].duration))

	_update_timeline.emit()


func remove_clip_timedata(a_clip_id: int, a_prev_track: int) -> void:
	for l_i: int in range(clips[a_clip_id].pts, clips[a_clip_id].pts + clips[a_clip_id].duration):
		_track_data[a_prev_track].remove_at(_track_data[a_prev_track].rfind(l_i))
	_update_timeline.emit()


#------------------------------------------------ TIMELINE FUNCTIONS
func get_track_id(a_pos_y: float) -> int:
	return roundi(a_pos_y / track_size)


func get_track_id_from_clip(a_clip_id: int) -> int:
	return get_track_id(_clip_nodes[a_clip_id].position.y)


func pos_to_frame(a_pos: float) -> int:
	return roundi(a_pos / timeline_scale)


func frame_to_pos(a_frame_nr) -> float:
	return a_frame_nr * timeline_scale


func get_end_frame_pts() -> int: # Returns last viable frame of project
	var l_end_timepoint: int = 0
	var l_keys: Array

	for l_track: Dictionary in tracks:
		l_keys = l_track.keys()
		if l_keys.size() == 0:
			continue

		l_keys.sort()
		l_end_timepoint = maxi(
				l_end_timepoint, 
				clips[l_track[l_keys[-1]]].pts + clips[l_track[l_keys[-1]]].duration)

	return l_end_timepoint


func set_timeline_scale(a_value: float) -> void:
	timeline_scale = clampf(a_value, Settings.timeline_scale_min, Settings.timeline_scale_max)
	_on_timeline_scale_changed.emit()

