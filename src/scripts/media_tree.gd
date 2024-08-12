extends TabContainer


const ICONS: Array[CompressedTexture2D] = [
		preload("res://icons/video_file.png"), preload("res://icons/audio_file.png"),
        preload("res://icons/image_file.png"), preload("res://icons/text_file.png"),
		preload("res://icons/color_file.png")]


var err: int = 0



func _ready() -> void: 
	err = Project._on_project_loaded.connect(_on_project_loaded)
	err += Project._on_file_added.connect(_on_file_added)
	if err:
		printerr("Problems occurred connecting functions in media tree!")

	for _i: int in ICONS.size():
		set_tab_icon(_i, ICONS[_i])
		set_tab_title(_i, "")


func _on_project_loaded() -> void:
	for l_folder: ScrollContainer in get_children():
		for l_file: Button in l_folder.get_node("VBox").get_children():
			l_file.queue_free()

	for l_file_id: int in Project.files:
		add_file(Project.get_file(l_file_id))


func _on_file_added(a_file_id: int) -> void:
	add_file(Project.get_file(a_file_id))


func add_file(a_file: File) -> void:
	var l_button: Button = Button.new()
	l_button.text = a_file.nickname 
	l_button.name = str(a_file.id)
	l_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	l_button.set_script(preload("res://scripts/classes/draggable.gd"))
	err = l_button.pressed.connect(func() -> void: Project._show_file_effects.emit(a_file.id))
	if err:
		printerr("Error connecting function in media tree on add file button!")

	match a_file.type:
		File.VIDEO: current_tab = get_node("VideoFiles").get_index()
		File.AUDIO: current_tab = get_node("AudioFiles").get_index()
		File.IMAGE: current_tab = get_node("ImageFiles").get_index()
		File.TEXT: current_tab = get_node("TextFiles").get_index()
		File.COLOR: current_tab = get_node("ColorFiles").get_index()
		File.GRADIENT: current_tab = get_node("GradientFiles").get_index()
		_: printerr("Invalid file!")

	get_current_tab_control().get_node("VBox").add_child(l_button)
