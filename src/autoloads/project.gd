extends DataManager

# TODO: When changing frame_rate, we need to re-calculate all video and audio files duration

signal _on_project_saved
signal _on_project_loaded

signal _on_file_added(file_id: int)

signal _on_timeline_scale_changed

signal _set_frame(frame_nr)
signal _set_frame_forced
signal _playhead_moved(value)

signal _is_resizing_clip(clip_id, track_id, direction) # direction: true = left, false = right


var _path: String = ""
var _file_data: Dictionary = {}
var _track_data: Array[PackedInt64Array] = []
var _clip_nodes: Dictionary = {}

var counter_file_id: int = 0
var counter_clip_id: int = 0

var file_data: Dictionary = {}

var tracks: Array[Dictionary] = [] # Inside Array are dictionaries. Key = frame number, Value = clip id

var clips: Dictionary = {}

var timeline_scale: float = 1. # One frame is a pixel in this scale

# Project quality related variables
var frame_rate: float = 30.
var resolution: Vector2i = Vector2i(1920, 1080)



func _ready() -> void:
	var l_args: PackedStringArray = OS.get_cmdline_args()
	for l_arg: String in l_args:
		if l_arg.get_extension() == "gozen":
			load_project(l_arg)
			break
	get_window().files_dropped.connect(_on_files_dropped)
	
	# Preparing tracks
	for _i: int in Settings.default_tracks:
		tracks.append({})
		_track_data.append(PackedInt64Array())


func open_project(a_path: String = "") -> void:
	if a_path.is_empty():
		var l_file_dialog: FileDialog = FileDialog.new()
		l_file_dialog.title = "Select GoZen project file"
		l_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		l_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		l_file_dialog.set_filters(PackedStringArray(["*.gozen; GoZen project file"]))
		l_file_dialog.file_selected.connect(open_project)
		get_tree().root.add_child(l_file_dialog)
		l_file_dialog.popup_centered(Vector2i(300,500))
		return
	if a_path.split('.')[-1] == "gozen":
		load_project(a_path)
	else:
		printerr("%s is an invalid project path!" % a_path)


func load_project(a_path: String) -> void:
	reset()
	_path = a_path
	load_data(_path)
	for l_file_id: int in file_data:
		_add_file_data(file_data[l_file_id])
	for _i: int in range(tracks.size()):
		_track_data.append([])
	_on_project_loaded.emit()


func save_project(a_path: String = "") -> void:
	if a_path.is_empty():
		var l_file_dialog: FileDialog = FileDialog.new()
		l_file_dialog.title = "Select save location for GoZen project"
		l_file_dialog.set_filters(PackedStringArray(["*.gozen ; GoZen project files"]))
		l_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		l_file_dialog.file_selected.connect(save_project)
		get_tree().root.add_child(l_file_dialog)
		l_file_dialog.popup_centered(Vector2i(600,600))
		return
	_path = a_path
	save_data(_path)
	_on_project_saved.emit()


func reset() -> void:
	_path = ""
	_file_data = {}
	counter_file_id = 0
	file_data = {}
	tracks = []
	counter_clip_id = 0
	clips = {}
	frame_rate = 30.


func _on_files_dropped(a_files: PackedStringArray) -> void:
	for l_file: String in a_files:
		add_file(l_file)


func _get_next_file_id() -> int:
	counter_file_id += 1
	return counter_file_id - 1


func _get_next_clip_id() -> int:
	counter_clip_id += 1
	return counter_clip_id - 1


func add_file(a_file_path: String) -> void:
	# This is for actual files on the system
	var l_file_id: int = _get_next_file_id()
	file_data[l_file_id] = File.create_file(a_file_path)
	_add_file_data(l_file_id)
	match file_data[l_file_id].type:
		File.VIDEO:
			file_data[l_file_id].duration = roundi(
				_file_data[l_file_id][0].get_total_frame_nr() / _file_data[l_file_id][0].get_framerate() * frame_to_timeline(frame_rate))
		File.AUDIO:
			file_data[l_file_id].duration = roundi(_file_data[l_file_id].get_length() * frame_rate)
	file_data[l_file_id].nickname = a_file_path.split('/')[-1]
	_on_file_added.emit(l_file_id)


func add_color_file(a_color: Color) -> void:
	var l_id: int = _get_next_file_id()
	file_data[l_id] = File.create_color_file(a_color)
	file_data[l_id].nickname = "Color-%s" % l_id
	_add_file_data(l_id)
	_on_file_added.emit(l_id)


func add_text_file(a_text: String) -> void:
	var l_id: int = _get_next_file_id()
	file_data[l_id] = File.create_text_file(a_text)
	file_data[l_id].nickname = "Text-%s" % l_id
	_add_file_data(l_id)
	_on_file_added.emit(l_id)


func add_gradient_file(a_gradient: GradientTexture2D) -> void:
	var l_id: int = _get_next_file_id()
	file_data[l_id] = File.create_gradient_file(a_gradient)
	file_data[l_id].nickname = "Gradient-%s" % l_id
	_add_file_data(l_id)
	_on_file_added.emit(l_id)


func add_clip(a_clip: ClipData, a_track_id: int) -> int:
	var l_id: int = _get_next_clip_id()
	a_clip.clip_id = l_id
	clips[l_id] = a_clip
	tracks[a_track_id][a_clip.timeline_start] = l_id
	add_clip_timedata(a_track_id, l_id)
	return l_id


func move_clip(a_clip_id: int, a_prev_pts: int, a_new_pts: int, a_prev_track_id: int, a_new_track_id: int) -> void:
	remove_clip_timedata(a_prev_track_id, a_clip_id)
	if !tracks[a_prev_track_id].erase(roundi(a_prev_pts / timeline_scale)):
		printerr("Trying to remove clip from track but non existent!")
	tracks[a_new_track_id][a_new_pts] = a_clip_id
	clips[a_clip_id].timeline_start = pos_to_frame(a_new_pts)
	add_clip_timedata(a_new_track_id, a_clip_id)


func remove_clip(a_clip_id: int, a_track_id: int) -> void:
	remove_clip_timedata(a_track_id, a_clip_id)
	if !tracks[a_track_id].erase(clips[a_clip_id].timeline_start):
		printerr("Trying to remove clip from track but non existent!")
	clips.erase(a_clip_id)


func resize_clip(a_clip_id: int, a_track_id: int, a_left: bool) -> void:
	remove_clip_timedata(a_track_id, a_clip_id)
	# TODO: If video file, check if position changed, if position changed, we need to change the clip start frame
	if file_data[clips[a_clip_id].file_id].type in [File.AUDIO, File.VIDEO] and a_left:
		clips[a_clip_id].start_frame += clips[a_clip_id].timeline_start - pos_to_frame(_clip_nodes[a_clip_id].position.x)
	tracks[a_track_id].erase(clips[a_clip_id].timeline_start)
	clips[a_clip_id].duration = pos_to_frame(_clip_nodes[a_clip_id].size.x)
	clips[a_clip_id].timeline_start = pos_to_frame(_clip_nodes[a_clip_id].position.x)
	tracks[a_track_id][clips[a_clip_id].timeline_start] = a_clip_id
	add_clip_timedata(a_track_id, a_clip_id)


func pos_to_frame(a_pos: float) -> int:
	return roundi(a_pos / Project.timeline_scale)


func frame_to_timeline(a_frame_nr) -> float:
	return a_frame_nr * Project.timeline_scale


	
func _add_file_data(a_file_id: int) -> void:
	var l_file: File = file_data[a_file_id]
	match l_file.type:
		File.VIDEO:
			_file_data[a_file_id] = []
			_file_data[a_file_id].resize(tracks.size())
			for l_i: int in tracks.size():
				_file_data[a_file_id][l_i] = VideoData.new()
				_file_data[a_file_id][l_i].open_video(l_file.path, l_i == 0)
		File.IMAGE:
			_file_data[a_file_id] = ImageTexture.create_from_image(Image.load_from_file(l_file.path))
		File.AUDIO:
			_file_data[a_file_id] = AudioImporter.load(l_file.path)


func get_end_frame_pts() -> int:
	# Get end frame presentation time stamp, Used to get the last valid frame from the project
	var l_end_timepoint: int = 0
	var l_keys: Array
	for l_track: Dictionary in tracks:
		l_keys = l_track.keys()
		if l_keys.size() == 0:
			continue
		l_keys.sort()
		l_end_timepoint = maxi(
				l_end_timepoint, 
				clips[l_track[l_keys[-1]]].timeline_start + clips[l_track[l_keys[-1]]].duration)
	return l_end_timepoint


func set_timeline_scale(a_value: float) -> void:
	timeline_scale = clampf(a_value, Settings.timeline_scale_min, Settings.timeline_scale_max)
	_on_timeline_scale_changed.emit()


func add_clip_timedata(a_track_id: int, a_clip_id: int) -> void:
	for _i: int in range(tracks.size() - _track_data.size()):
		_track_data.append([])

	# Adding clip data
	_track_data[a_track_id].append_array(range(
		clips[a_clip_id].timeline_start, 
		clips[a_clip_id].timeline_start + clips[a_clip_id].duration))


func remove_clip_timedata(a_track_id: int, a_clip_id: int) -> void:
	for l_i: int in range(clips[a_clip_id].timeline_start, clips[a_clip_id].timeline_start + clips[a_clip_id].duration):
		_track_data[a_track_id].remove_at(_track_data[a_track_id].rfind(l_i))

