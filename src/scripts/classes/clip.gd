class_name Clip extends Node


var file_id: int
var timeline_start: int = 0
var duration: int = 0

# Only need to be set for videos
var start_frame: int = 0 
var end_frame: int = 0


func get_texture(a_frame_nr: int) -> Texture:
	match Project.file_data[file_id].type:
		File.TEXT:
			print("Not implemented yet!")
		File.IMAGE:
			# TODO: Don't run this function for pictures when picture is already loaded.
			return ImageTexture.create_from_image(Project._file_data[file_id])
		File.VIDEO:
			print("Not implemented yet!")
		File.COLOR:
			print("Not implemented yet!")
		File.AUDIO:
			print("Not implemented yet!")
		File.GRADIENT:
			print("Not implemented yet!")
	printerr("Couldn't load texture!!")
	return Texture.new()

