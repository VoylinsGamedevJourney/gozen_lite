extends DataManager


const PATH: String = "user://settings"


var default_tracks: int = 6

var default_duration_image: int = 150:

	set(a_value): set_duration_image(a_value)
var default_duration_text: int = 150:
	set(a_value): set_duration_text(a_value)
var default_duration_color: int = 150:
	set(a_value): set_duration_color(a_value)
var default_duration_gradient: int = 150:
	set(a_value): set_duration_gradient(a_value)

var timeline_scale_max: float = 5.6
var timeline_scale_min: float = 0.1

var action_size: int = 100 # Redo and undo limit



func _ready():
	if FileAccess.file_exists(PATH):
		load_data(PATH)
	else:
		save_data(PATH)


func set_duration_image(a_value: int) -> void:
	if a_value < 0:
		default_duration_image = 1
		return
	default_duration_image = a_value


func set_duration_text(a_value: int) -> void:
	if a_value < 0:
		default_duration_text = 1
		return
	default_duration_text = a_value


func set_duration_color(a_value: int) -> void:
	if a_value < 0:
		default_duration_color = 1
		return
	default_duration_color = a_value


func set_duration_gradient(a_value: int) -> void:
	if a_value < 0:
		default_duration_gradient = 1
		return
	default_duration_gradient = a_value

