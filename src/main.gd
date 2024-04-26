extends Control

const VIDEO_PATH: String = "/storage/Youtube/02 - Gamedev Journey/vgj Outro.mp4"

@onready var timeline: HSlider = $VBox/Timeline
@onready var texture: TextureRect = $VBox/Panel/TextureRect

var video: Video = Video.new()
var is_playing: bool = false


func _ready() -> void:
	video.open_video(VIDEO_PATH)
	$AudioStream1.stream = video.get_audio()
	$AudioStream1.play()


func _process(a_delta: float) -> void:
	pass


func _on_play_pause_button_pressed():
	is_playing = !is_playing
	if is_playing:
		pass
	else:
		pass
