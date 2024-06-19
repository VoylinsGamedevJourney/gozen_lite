extends DataManager


const PATH: String = "user://settings"


var default_video_tracks: int = 3
var default_audio_tracks: int = 3


func _ready():
	if FileAccess.file_exists(PATH):
		load_data(PATH)
	else:
		save_data(PATH)

