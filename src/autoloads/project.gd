extends DataManager

signal _on_project_saved
signal _on_project_loaded

signal _on_file_added(file_id: int)


var _path: String = ""
var _file_data: Dictionary = {}

var file_id: int = 0
var file_data: Dictionary = {}

var tracks_video: Array = [] # Inside Array are dictionaries 
var tracks_audio: Array = [] # Key = frame number, Value = clip id

var clip_video_id: int = 0
var clip_audio_id: int = 0
var clips_video: Dictionary = {}
var clips_audio: Dictionary = {}



func _ready() -> void:
	var l_args: PackedStringArray = OS.get_cmdline_args()
	for l_arg: String in l_args:
		if l_arg.get_extension() == "gozen":
			load_project(l_arg)
			break
	get_window().files_dropped.connect(_on_files_dropped)


func load_project(a_path: String) -> void:
	_path = a_path
	load_data(_path)
	_on_project_loaded.emit()
	%TimelinePanel.load_project()


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


func _get_next_id() -> int:
	file_id += 1
	return file_id - 1


func add_file(a_file_path: String) -> void:
	var l_id: int = _get_next_id()
	file_data[l_id] = File.create_file(a_file_path)
	match file_data[l_id]:
		File.VIDEO:
			_file_data[l_id] = Video.new()
			_file_data[l_id].open_video(a_file_path)
		File.IMAGE: 
			_file_data[l_id] = Image.load_from_file(a_file_path)
		File.AUDIO:
			_file_data[l_id] = load(a_file_path)
	_on_file_added.emit(l_id)


func add_color_file(a_color: Color) -> void:
	var l_id: int = _get_next_id()
	file_data[l_id] = File.create_color_file(a_color)
	_on_file_added.emit(l_id)


func add_text_file(a_tree_location: String, a_text: String) -> void:
	var l_id: int = _get_next_id()
	file_data[l_id] = File.create_text_file(a_text)
	_on_file_added.emit(l_id)


func add_gradient_file(a_tree_location: String, a_gradient: GradientTexture2D) -> void:
	var l_id: int = _get_next_id()
	file_data[l_id] = File.create_gradient_file(a_gradient)
	_on_file_added.emit(l_id)

