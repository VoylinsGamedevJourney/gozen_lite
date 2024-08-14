extends PanelContainer


func _ready() -> void:
	var l_args: PackedStringArray = OS.get_cmdline_args()
	for l_arg: String in l_args:
		if l_arg.get_extension() == "gozen":
			Project.load_project(l_arg)
			break

	(get_node("RenderBackground") as Control).visible = false
