extends TabContainer
# ColorFiles contains both colors and gradients



func _ready() -> void:
	File.create_file("test.mp4")
	Project._on_project_loaded.connect(_on_project_loaded)
	Project._on_file_added.connect(_on_file_added)


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
	l_button.type = Draggable.FILE

	match a_file.type:
		File.VIDEO: current_tab = get_node("VideoFiles").get_index()
		File.AUDIO: current_tab = get_node("AudioFiles").get_index()
		File.IMAGE: current_tab = get_node("ImageFiles").get_index()
		File.TEXT: current_tab = get_node("TextFiles").get_index()
		File.COLOR: current_tab = get_node("ColorFiles").get_index()
		File.GRADIENT: current_tab = get_node("GradientFiles").get_index()
		_: printerr("Invalid file!")
	get_current_tab_control().get_node("VBox").add_child(l_button)
