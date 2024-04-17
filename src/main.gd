extends Control

const VIDEO_PATH: String = "/storage/Youtube/02 - Gamedev Journey/vgj Outro.mp4"

@onready var timeline: HSlider = $VBox/Timeline
@onready var texture: TextureRect = $VBox/Panel/TextureRect


var is_playing: bool = false


func _ready() -> void:
	var video: Video = Video.new()
	video.open_video(VIDEO_PATH)


func _process(a_delta: float) -> void:
	pass


func _on_play_pause_button_pressed():
	is_playing = !is_playing
	if is_playing:
		pass
	else:
		pass
