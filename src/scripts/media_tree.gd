extends TabContainer



func _ready() -> void:
	Project._on_project_loaded.connect(_on_project_loaded)
	Project._on_file_added.connect(_on_file_added)
	# Add icons
	set_tab_icon(0, preload("res://icons/video_file.png"))
	set_tab_icon(1, preload("res://icons/audio_file.png"))
	set_tab_icon(2, preload("res://icons/image_file.png"))
	set_tab_icon(3, preload("res://icons/text_file.png"))
	set_tab_icon(4, preload("res://icons/color_file.png"))
	# Set texts
	set_tab_title(0, "")
	set_tab_title(1, "")
	set_tab_title(2, "")
	set_tab_title(3, "")
	set_tab_title(4, "")


func _on_project_loaded() -> void:
	for l_folder: ScrollContainer in get_children(): # Clear folders
		for l_file: Button in l_folder.get_node("VBox").get_children():
			l_file.queue_free()
	for l_file_id: int in Project.file_data: # Populate tree
		add_file(l_file_id, Project.file_data[l_file_id])


func _on_file_added(a_file_id: int) -> void:
	add_file(a_file_id, Project.file_data[a_file_id])


func add_file(a_file_id: int, a_file: File) -> void:
	var l_button: Button = Button.new()
	l_button.text = a_file.nickname 
	l_button.name = str(a_file_id)
	l_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	l_button.pressed.connect(EffectsPanel.show_file_effects.bind(a_file_id))
	l_button.set_script(preload("res://scripts/classes/draggable.gd"))

	match a_file.type:
		File.VIDEO: current_tab = get_node("VideoFiles").get_index()
		File.AUDIO: current_tab = get_node("AudioFiles").get_index()
		File.IMAGE: current_tab = get_node("ImageFiles").get_index()
		File.TEXT: current_tab = get_node("TextFiles").get_index()
		File.COLOR: current_tab = get_node("ColorFiles").get_index()
		File.GRADIENT: current_tab = get_node("GradientFiles").get_index()
		_: printerr("Invalid file!")
	get_current_tab_control().get_node("VBox").add_child(l_button)
