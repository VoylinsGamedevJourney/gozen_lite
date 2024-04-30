extends Control

const VIDEO_PATH: String = "/storage/Youtube/02 - Gamedev Journey/vgj Outro.mp4"

@onready var timeline: HSlider = $VBox/Timeline
@onready var texture: TextureRect = $VBox/Panel/TextureRect

var video: Video = Video.new()
var is_playing: bool = false


func _ready() -> void:
	video.open_video(VIDEO_PATH)
	print(video.get_total_frame_nr())
	var start_time := Time.get_ticks_msec()
	$VBox/Panel/TextureRect.texture.set_image(video.seek_frame(560))
	print(Time.get_ticks_msec()- start_time)
	#$AudioStream1.stream = video.get_audio()
	#$AudioStream1.play()


func _process(a_delta: float) -> void:
	if is_playing:
		$VBox/Panel/TextureRect.texture.set_image(video.next_frame())


func _on_play_pause_button_pressed():
	is_playing = !is_playing
	if is_playing:
		pass
	else:
		pass
