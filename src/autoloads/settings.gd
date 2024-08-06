extends DataManager


const PATH: String = "user://settings"


var default_tracks: int = 6

var duration_image: int = 150
var duration_text: int = 150
var duration_color: int = 150
var duration_gradient: int = 150

var timeline_scale_max: float = 5.6
var timeline_scale_min: float = 0.1


func _ready():
	if FileAccess.file_exists(PATH):
		load_data(PATH)
	else:
		save_data(PATH)
