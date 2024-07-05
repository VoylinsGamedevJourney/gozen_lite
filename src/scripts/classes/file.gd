class_name File extends Resource

enum {
	# Debug
	DUPLICATE = -2,
	ERROR = -1,
	EMPTY = 0,
	# Generated
	COLOR = 1, 
	TEXT = 2, 
	GRADIENT = 3,
	# Files
	VIDEO = 10,
	IMAGE = 11,
	AUDIO = 12,
}


const VIDEO_EXT: PackedStringArray = ["mp4","mov","avi","mkv","webm","flv","mpeg","mpg","wmv","asf","vob","ts","m2ts","mts","3gp","3g2"]
const AUDIO_EXT: PackedStringArray = ["ogg","wav","mp3"]
const IMAGE_EXT: PackedStringArray = ["png","jpg","svg","webp","bmp","tga","dds","hdr","exr"]


# Default
var type: int = -1
var nickname: String = ""
var duration: int = 10 # duration in frames
#var master_shader # TODO: Add system


# For actual files
var path: String = ""
var sha256: String = ""

# For generated files 
var color: Color
var gradient: GradientTexture2D
var text: String = ""



static func create_file(a_file_path: String) -> File:
	# Figure out what file type it is	
	var l_file: File = File.new()
	var l_ext: String = a_file_path.get_extension().to_lower()

	if l_ext in VIDEO_EXT:
		l_file.type = VIDEO
	elif l_ext in AUDIO_EXT:
		l_file.type = AUDIO
	elif l_ext in IMAGE_EXT:
		l_file.type = IMAGE
		l_file.duration = Settings.duration_image
	else:
		l_file.type = ERROR
		return l_file

	# Checking for duplicate files
	for l_file_id: int in Project.file_data:
		if Project.file_data[l_file_id].path == a_file_path:
			l_file.type = DUPLICATE
			return l_file

	l_file.nickname = a_file_path.get_file()
	l_file.path = a_file_path
	l_file.sha256 = FileAccess.get_sha256(a_file_path)

	return l_file


static func create_color_file(a_color: Color) -> File:
	var l_file: File = File.new()
	l_file.type = COLOR
	l_file.color = a_color
	l_file.duration = Settings.duration_color
	return l_file


static func create_text_file(a_text: String) -> File:
	var l_file: File = File.new()
	l_file.type = TEXT
	l_file.text = a_text
	l_file.duration = Settings.duration_text
	return l_file


static func create_gradient_file(a_gradient: GradientTexture2D) -> File:
	var l_file: File = File.new()
	l_file.type = GRADIENT
	l_file.gradient = a_gradient
	l_file.duration = Settings.duration_gradient
	return l_file

