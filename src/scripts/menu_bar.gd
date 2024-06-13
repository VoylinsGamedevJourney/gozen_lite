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
	menu[PROJECT].add_item("Close editor (Ctrl+Q")

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
