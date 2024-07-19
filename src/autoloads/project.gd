extends DataManager


signal _on_project_saved
signal _on_project_loaded

signal _on_file_added(file_id: int)


var _path: String = ""
var _file_data: Dictionary = {}

var file_id: int = 0
var file_data: Dictionary = {}

var tracks: Array[Dictionary] = [] # Inside Array are dictionaries. Key = frame number, Value = clip id

var clip_id: int = 0
var clips: Dictionary = {}

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
	_on_project_loaded.emit()
	Timeline.instance.load_project()


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
	file_id = 0
	file_data = {}
	tracks = []
	clip_id = 0
	clips = {}
	frame_rate = 30.


func _on_files_dropped(a_files: PackedStringArray) -> void:
	for l_file: String in a_files:
		add_file(l_file)


func _get_next_file_id() -> int:
	file_id += 1
	return file_id - 1


func _get_next_clip_id() -> int:
	clip_id += 1
	return clip_id - 1


func add_file(a_file_path: String) -> void:
	var l_id: int = _get_next_file_id()
	file_data[l_id] = File.create_file(a_file_path)
	match file_data[l_id].type:
		File.VIDEO:
			_file_data[l_id] = Video.new()
			_file_data[l_id].open_video(a_file_path)
			file_data[l_id].duration = _file_data[l_id].get_total_frame_nr() 
		File.IMAGE:
			_file_data[l_id] = Image.load_from_file(a_file_path)
		File.AUDIO:
			_file_data[l_id] = load(a_file_path)
			file_data[l_id].duration = _file_data[l_id].get_length() # This is in seconds and not frames
	file_data[l_id].nickname = a_file_path.split('/')[-1]
	_on_file_added.emit(l_id)


func add_color_file(a_color: Color) -> void:
	var l_id: int = _get_next_file_id()
	file_data[l_id] = File.create_color_file(a_color)
	file_data[l_id].nickname = "Color-%s" % l_id
	_on_file_added.emit(l_id)


func add_text_file(a_text: String) -> void:
	var l_id: int = _get_next_file_id()
	file_data[l_id] = File.create_text_file(a_text)
	file_data[l_id].nickname = "Text-%s" % l_id
	_on_file_added.emit(l_id)


func add_gradient_file(a_gradient: GradientTexture2D) -> void:
	var l_id: int = _get_next_file_id()
	file_data[l_id] = File.create_gradient_file(a_gradient)
	file_data[l_id].nickname = "Gradient-%s" % l_id
	_on_file_added.emit(l_id)


func add_clip(a_clip: Clip, a_track_id: int) -> int:
	var l_id: int = _get_next_clip_id()
	clips[l_id] = a_clip
	tracks[a_track_id][a_clip.timeline_start] = l_id
	return l_id
	

func get_end_frame_timepoint() -> int:
	var l_end_timepoint: int = 0
	var l_keys: Array
	var l_clip: Clip
	for l_track: Dictionary in tracks:
		l_keys = l_track.keys()
		if l_keys.size() != 0:
			l_keys.sort()
			l_clip = clips[l_track[l_keys[-1]]]
			l_end_timepoint = maxi(l_end_timepoint, l_clip.timeline_start + l_clip.duration)
	return l_end_timepoint
