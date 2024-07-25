class_name Clip extends Node


var file_id: int
var timeline_start: int = 0
var duration: int = 0

# Only need to be set for videos
var start_frame: int = 0 
var end_frame: int = 0
var current_frame: int = -1
var video_frame_nr: int = 0
var frame_skip: int = 0
var video_data: Video


func get_image() -> Image:
	return Project._file_data[file_id]


func get_video_frame(a_is_playing: bool) -> Image:
	if video_data == null:
		video_data = Video.new()
		video_data.open_video(Project.file_data[file_id].path, false)
	if frame_skip < 0 or frame_skip > 8 or !a_is_playing:
		video_frame_nr = current_frame
		return video_data.seek_frame(current_frame)
	else:
		for l_i: int in frame_skip:
			if l_i + 1 == frame_skip:
				video_frame_nr = current_frame
				return video_data.next_frame()
			video_data.next_frame()
	printerr("Something went wrong fetching video frame")
	return null


func next_frame_available(a_frame_nr: int) -> bool: # Only for video
	current_frame = video_frame_conversion(a_frame_nr)
	if current_frame != video_frame_nr:
		frame_skip = -1 if current_frame < video_frame_nr else current_frame - video_frame_nr
		return true
	frame_skip = -1
	return false


func get_texture(a_frame_nr: int) -> Texture:
	match Project.file_data[file_id].type:
		File.TEXT:
			print("Not implemented yet!")
		File.COLOR:
			print("Not implemented yet!")
		File.AUDIO:
			print("Not implemented yet!")
		File.GRADIENT:
			print("Not implemented yet!")
	printerr("Couldn't load texture!!")
	return Texture.new()


func video_frame_conversion(a_frame_nr) -> int:
	return floori(a_frame_nr - timeline_start - start_frame / Project.frame_rate * Project._file_data[file_id].get_framerate())
