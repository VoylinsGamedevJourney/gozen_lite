extends DataManager

signal _on_project_saved
signal _on_project_loaded


var _path: String = ""


func _ready() -> void:
	var l_args: PackedStringArray = OS.get_cmdline_args()
	for l_arg: String in l_args:
		if l_arg.get_extension() == "gozen":
			load_project(l_arg)
			break


func load_project(a_path: String) -> void:
	_path = a_path
	load_data(_path)
	_on_project_loaded.emit()


func save_project(a_path: String = _path) -> void:
	# TODO: If path is empty, get input for path
	_path = a_path
	save_data(_path)
	_on_project_saved.emit()

