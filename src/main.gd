extends Control


@onready var timeline: HSlider = $VBox/Timeline
@onready var texture: TextureRect = $VBox/Panel/TextureRect

var video: Video
var is_playing: bool = false
var was_playing: bool = false

var current_frame: int = 1
var framerate: float = 0
var max_frame: int = 0
var frame_time: float = 0

var time_elapsed: float = 0.0
var dragging: bool = false

var fast_speed: int = 4 # Fast forward/Rewind
var fast_rewind: bool = false
var fast_forward: bool = false

var variable_frame_rate: bool = false

var task_id: int = -1



func _ready() -> void:
	# Making it possible for files to be dropped or the player to be opened with a file
	if OS.get_cmdline_args().size() > 1:
		video = Video.new()
		video.open_video(OS.get_cmdline_args()[1])
		after_video_open()
	get_window().files_dropped.connect(on_video_drop)


func on_video_drop(a_files: PackedStringArray) -> void:
	$LoadingLabel.visible = true
	video = Video.new()
	task_id = WorkerThreadPool.add_task(video.open_video.bind(a_files[0]))


func open_video(a_file: String) -> void:
	video.open_video(a_file)


func after_video_open() -> void:
	$AudioStream1.stream = video.get_audio()
	is_playing = false
	framerate = video.get_framerate()
	max_frame = video.get_total_frame_nr()
	frame_time = 1.0 / framerate
	seek_frame(1)
	variable_frame_rate = video.is_framerate_variable()
	$VBox/Timeline.max_value = max_frame
	$LoadingLabel.visible = false


func is_video_open() -> bool:
	if !video:
		return false
	return video.is_video_open()


func _process(a_delta: float) -> void:
	if task_id != -1 and WorkerThreadPool.is_task_completed(task_id):
		WorkerThreadPool.wait_for_task_completion(task_id)
		task_id = -1
		$LoadingLabel.visible = false
		if is_video_open():
			after_video_open()
		else:
			printerr("Couldn't open video!")
	elif !is_video_open():
		return
	
	if is_playing:
		time_elapsed += a_delta
		if time_elapsed < frame_time:
			return
		
		while time_elapsed >= frame_time:
			time_elapsed -= frame_time
			current_frame += 1
		
		if current_frame > max_frame + 50:
			if dragging:
				return
			is_playing = !is_playing
			seek_frame(1)
			$AudioStream1.set_stream_paused(true)
		else:
			if variable_frame_rate:
				frame_time = video.get_variable_frame_time()
			$VBox/Panel/TextureRect.texture.set_image(video.next_frame())
			if !dragging:
				$VBox/Timeline.value = current_frame
	elif fast_rewind:
		seek_frame(current_frame - fast_speed)
	elif fast_forward:
		seek_frame(current_frame + fast_speed)


func seek_frame(a_frame_nr: int) -> void:
	if !is_video_open():
		return
	#current_frame = clampi(a_frame_nr, 1, max_frame - 1)
	current_frame = a_frame_nr
	if !is_playing:
		$AudioStream1.set_stream_paused(false)
	$AudioStream1.seek(current_frame/framerate)
	if !is_playing:
		$AudioStream1.set_stream_paused(true)
	$VBox/Panel/TextureRect.texture.set_image(video.seek_frame(current_frame))
	if variable_frame_rate:
		frame_time = video.get_variable_frame_time()
	if !dragging:
		$VBox/Timeline.value = current_frame


func _on_play_pause_button_pressed():
	if !is_video_open():
		return
	is_playing = !is_playing
	if is_playing:
		$AudioStream1.play($AudioStream1.get_playback_position())
		seek_frame(current_frame)
		$VBox/HBox/PlayPauseButton.texture_normal = preload("res://icons/pause_48dp_FILL1_wght400_GRAD0_opsz48.png")
	else:
		$VBox/HBox/PlayPauseButton.texture_normal = preload("res://icons/play_arrow_48dp_FILL1_wght400_GRAD0_opsz48.png")
	$AudioStream1.set_stream_paused(!is_playing)


func _on_timeline_value_changed(_value: float) -> void:
	if dragging:
		seek_frame($VBox/Timeline.value)


func _on_timeline_drag_started() -> void:
	dragging = true
	if is_playing:
		$AudioStream1.set_stream_paused(true)


func _on_timeline_drag_ended(_value: bool) -> void:
	dragging = false
	if is_playing:
		$AudioStream1.set_stream_paused(false)
		$AudioStream1.seek($VBox/Timeline.value/framerate)


func _on_fast_rewind_button_down() -> void:
	was_playing = is_playing
	is_playing = false
	$AudioStream1.set_stream_paused(!is_playing)
	fast_rewind = true


func _on_fast_rewind_button_up() -> void:
	is_playing = was_playing
	$AudioStream1.set_stream_paused(!was_playing)
	fast_rewind = false


func _on_fast_forward_button_down() -> void:
	was_playing = is_playing
	is_playing = false
	$AudioStream1.set_stream_paused(!is_playing)
	fast_forward = true


func _on_fast_forward_button_up() -> void:
	is_playing = was_playing
	$AudioStream1.set_stream_paused(!was_playing)
	fast_forward = false
