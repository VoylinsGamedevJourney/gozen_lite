class_name File extends Resource

enum {
	# Generated
	COLOR = 1, TEXT = 4, GRADIENT = 8,
	# Files
	VIDEO = 16,	IMAGE = 32,	AUDIO = 64,
}


const VIDEO_EXT: PackedStringArray = ["mp4","mov","avi","mkv","webm","flv","mpeg",
									  "mpg","wmv","asf","vob","ts","m2ts","mts","3gp","3g2"]
const AUDIO_EXT: PackedStringArray = ["ogg","wav","mp3"]
const IMAGE_EXT: PackedStringArray = ["png","jpg","svg","webp","bmp","tga","dds","hdr","exr"]


var id: int
var type: int = -1
var nickname: String
var duration: int = 10

# For actual files
var path: String
var sha256: String

# Generated files 
var color: Color
var gradient: GradientTexture2D

# Text variables
var text: String
var text_settings: LabelSettings

# Variables for generated
var position: Vector2 = Vector2.ZERO
var size: Vector2i



#------------------------------------------------ FILE CREATE STATIC FUNCTIONS
static func create_file(a_file_path: String) -> bool:
	var l_file: File = File.new()
	var l_extension: String = a_file_path.get_extension().to_lower()

	l_file.nickname = a_file_path.get_file()
	l_file.path = a_file_path
	l_file.sha256 = FileAccess.get_sha256(a_file_path)

	# Checking for duplicate files
	for l_file_id: int in Project.files:
		if check_duplicate(Project.get_file(l_file_id), l_file):
			return false

	if l_extension in VIDEO_EXT:
		# TODO: Change this when frame rate gets changed
		l_file.type = VIDEO
	elif l_extension in AUDIO_EXT:
		# TODO: Change this when frame rate gets changed
		l_file.type = AUDIO
	elif l_extension in IMAGE_EXT:
		l_file.type = IMAGE
		l_file.duration = Settings.default_duration_image
	else:
		return false

	_init_file(l_file)
	return true


static func create_color_file(a_color: Color) -> void:
	var l_file: File = File.new()
	l_file.type = COLOR
	l_file.color = a_color
	l_file.duration = Settings.default_duration_color
	l_file.size = Project.resolution

	_init_file(l_file)


static func create_text_file(a_text: String) -> void:
	var l_file: File = File.new()
	l_file.type = TEXT
	l_file.text = a_text
	l_file.duration = Settings.default_duration_text
	l_file.text_settings = LabelSettings.new()
	l_file.size = Project.resolution

	_init_file(l_file)


static func create_gradient_file(a_gradient: GradientTexture2D) -> void:
	var l_file: File = File.new()
	l_file.type = GRADIENT
	l_file.gradient = a_gradient
	l_file.duration = Settings.default_duration_gradient
	l_file.size = Project.resolution

	_init_file(l_file)


static func check_duplicate(a_file_1: File, a_file_2: File) -> bool:
	if a_file_1.path == a_file_2.path:
		return true
	return a_file_1.sha256 == a_file_2.sha256


static func _init_file(a_file: File) -> void:
	Project.counter_file_id += 1
	a_file.id = Project.counter_file_id
	if !a_file.add_file_data():
		printerr("Something went wrong adding file data, removing file entry!")
		Project._file_data.erase[a_file.id]
		Project.counter_file_id -= 1
		return

	if a_file.type == VIDEO:
		a_file._set_duration_video()
	elif a_file.type == AUDIO:
		a_file._set_duration_audio()

	Project.files[a_file.id] = a_file
	Project._on_file_added.emit(a_file.id)


#------------------------------------------------ OTHER FUNCTIONS
func _set_duration_video() -> void:
	duration = round(Project.get_video_file_data(id, 0).get_total_frame_nr() /
					 Project.get_video_file_data(id, 0).get_framerate() *
					 Project.frame_to_pos(roundi(Project.frame_rate)))


func _set_duration_audio() -> void:
	var l_audio_stream: AudioStream = Project._file_data[id]
	duration = round(l_audio_stream.get_length() * Project.frame_rate)


func add_file_data() -> bool:
	match type:
		VIDEO:
			var l_array: Array[VideoData] = []
			if l_array.resize(Project.tracks.size()):
				printerr("Couldn't resize array successfully for VideoData!")
			Video.get_video_file_meta(path)
			Project.set_file_data(id, l_array)
			
			for _i: int in Project.tracks.size():
				var l_video_data: VideoData = VideoData.new()
				if !l_video_data.open_video(path, _i == 0):
					return false
				Project.set_video_file_data(id, _i, l_video_data)
		IMAGE:
			Project.set_file_data(id, ImageTexture.create_from_image(Image.load_from_file(path)))
		AUDIO:
			Project.set_file_data(id, AudioImporter.load(path))
		COLOR:
			var l_color_rect: ColorRect = ColorRect.new()
			l_color_rect.color = color
			l_color_rect.size = Project.resolution
			Project.set_file_data(id, l_color_rect)
		GRADIENT:
			var l_texture_rect: TextureRect = TextureRect.new()
			l_texture_rect.texture = gradient
			Project.set_file_data(id, l_texture_rect)
		TEXT:
			var l_label: Label = Label.new()
			l_label.text = text
			l_label.label_settings = text_settings
			Project.set_file_data(id, l_label)
	return true

