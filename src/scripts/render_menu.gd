extends PanelContainer


var renderer: Renderer

var video_codecs: Array = []
var audio_codecs: Array = []

var is_rendering: bool = false
var path: String = ""
var bit_rate: int = 0
var gop_size: int = 0
var video_codec: int = 0
var audio_codec: int = 0

var start_time: int
var err: int = 0



func _ready() -> void:
	visible = false
	
	err = Project._open_render_menu.connect(open_menu)
	err += Project._send_frame.connect(send_frame)
	err += Project._sending_frames_finished.connect(finished)
	if err:
		printerr("Something went wrong connecting functions in render menu!")


	var l_supported_codecs: Dictionary = Renderer.get_supported_codecs()
	for l_entry: String in l_supported_codecs.video:
		video_codecs.append(l_supported_codecs.video[l_entry].codec_id)
		if l_supported_codecs.video[l_entry].hardware_accel:
			(%VideoCodecOptionButton as OptionButton).add_item(l_entry + '*')
		else:
			(%VideoCodecOptionButton as OptionButton).add_item(l_entry)
	for l_entry: String in l_supported_codecs.audio:
		audio_codecs.append(l_supported_codecs.audio[l_entry].codec_id)
		if l_supported_codecs.audio[l_entry].hardware_accel:
			(%AudioCodecOptionButton as OptionButton).add_item(l_entry + '*')
		else:
			(%AudioCodecOptionButton as OptionButton).add_item(l_entry)


func _on_close_button_pressed() -> void:
	if !is_rendering:
		visible = false


func open_menu() -> void:
	if visible and is_rendering:
		return
	visible = !visible


func start_rendering() -> void:
	if Project.get_end_frame_pts() == 0:
		printerr("Nothing to render!")
		pass

	# Checking if file path is valid
	path = (%OutputFileLineEdit as LineEdit).text
	if path == "":
		print("Path is empty")
		return
	var l_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if FileAccess.get_open_error():
		print("File path returns open error '%s'" % FileAccess.get_open_error())
		return
	l_file.close()

	bit_rate = ((%BitRateSpinBox as SpinBox).value as int) * 1000
	gop_size = (%GopSizeSpinBox as SpinBox).value as int
	video_codec = video_codecs[(%VideoCodecOptionButton as OptionButton).selected]

	renderer = Renderer.new()
	renderer.set_resolution(Project.resolution)
	renderer.set_framerate(Project.frame_rate)
	renderer.set_bit_rate(bit_rate)
	renderer.set_gop_size(gop_size)
	renderer.set_output_file_path(path)
	renderer.set_video_codec(video_codec)
	renderer.set_audio_codec(audio_codec)
	renderer.set_render_audio(false)

	start_time = Time.get_ticks_msec()
	print("Renderer opening")
	err = renderer.open()
	if err:
		printerr("Something went wrong opening renderer! ", err)
		return
	is_rendering = true
	Project._is_rendering.emit(true)


func send_frame(a_frame: Image) -> void:
	if !is_rendering:
		print("Not rendering atm")
		return
	render_array.append(a_frame)
	err = renderer.send_frame(a_frame)
	if err:
		printerr("Something went wrong sending frame to renderer! ", err)


func finished() -> void:
	print("Renderer closing")	
	err = renderer.close()
	if err:
		printerr("Something went wrong closing renderer! ", err)
	is_rendering = false
	Project._is_rendering.emit(false)
	print("Total render time took %s seconds for a video of %s seconds." % [snapped((Time.get_ticks_msec() - start_time) * 0.001, 0.01), snapped(Project.get_end_frame_pts() / Project.frame_rate, 0.01)])
