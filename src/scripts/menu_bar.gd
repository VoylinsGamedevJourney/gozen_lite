extends MenuBar


enum { PROJECT, TOOLS, HELP } 


var menu: Array[PopupMenu] = []


func _ready() -> void:
	add_main_menu("Project")
	add_main_menu("Tools")
	add_main_menu("Help")

	# Setting up Project popup
	menu[PROJECT].add_item("New project (Ctrl+N)")
	menu[PROJECT].add_item("Open project (Ctrl+O)")
	menu[PROJECT].add_item("Open recent project")
	menu[PROJECT].add_separator()
	menu[PROJECT].add_item("Save project (Ctrl+S)")
	menu[PROJECT].add_item("Save project ... (Ctrl+Shift+S)")
	menu[PROJECT].add_separator()
	menu[PROJECT].add_item("Render project (Ctrl+Enter)")
	menu[PROJECT].add_separator()
	menu[PROJECT].add_item("Close editor (Ctrl+Q)")
	menu[PROJECT].id_pressed.connect(_on_menu_project_id_pressed)

	# Setting up Tools popup
	menu[TOOLS].add_item("Settings")
	menu[TOOLS].add_item("Project settings")

	# Setting up Help popup
	menu[HELP].add_item("Support GoZen")
	menu[HELP].add_item("Open help (Ctrl+H)")
	menu[HELP].add_item("Editor info")



func add_main_menu(a_name: String) -> void:
	var l_popup: PopupMenu = PopupMenu.new()
	l_popup.name = a_name
	menu.append(l_popup)
	add_child(l_popup)


func _on_menu_project_id_pressed(a_id: int) -> void:
	match a_id:
		0: # New project
			Project.reset()
		1: # Open project
			print("Not implemented yet!") # TODO: WWe need the popup handler for this to work
			#Project.open_project()
		2: # Open recent project
			print("Not implemented yet!")
			pass # TODO: Make a submenu popup show with the 10 most recent projects
		4: # Save project
			Project.save_project(Project._path)
		5: # Save project as ...
			Project.save_project()
		7: # Render project
			print("Not implemented yet!")
			pass # TODO: Show render menu	
		9: # Quit editor
			# TODO: Check for changes and save them if needed
			get_tree().quit()

