extends DataManager


const PATH: String = "user://settings"


func _ready():
	if FileAccess.file_exists(PATH):
		load_data(PATH)
	else:
		save_data(PATH)

