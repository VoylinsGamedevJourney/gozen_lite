extends DataManager

signal _on_project_saved
signal _on_project_loaded

signal _on_file_added(file_id: int)


var _path: String = ""
var _file_data: Dictionary = {}
var _track_data: Array[Array] = []

var file_id: int = 0
var file_data: Dictionary = {}

var tracks: Array[Dictionary] = [] # Inside Array are dictionaries. Key = frame number, Value = clip id

var clip_id: int = 0
var clips: Dictionary = {}



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
		_track_data.append([])


func load_project(a_path: String) -> void:
	_path = a_path
	tracks = []
	_track_data = []
	load_data(_path)
	_on_project_loaded.emit()
	%TimelinePanel.load_project()
	# TODO: Load _track_data


func save_project(a_path: String = _path) -> void:
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
	match file_data[l_id]:
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
	_track_data[a_track_id].append_array(range(a_clip.timeline_start, a_clip.timeline_start + a_clip.duration))
	return l_id
	
