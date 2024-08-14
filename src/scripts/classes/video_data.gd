class_name VideoData extends Node


var video_data: Video

var current_frame: int = -1 # Current frame from timeline
var video_frame_nr: int = 0 # Current frame from video file
var frame_skip: int = 0 # Amount of frame number difference

var err: int = 0


func open_video(a_path: String, a_load_audio: bool) -> bool:
	video_data = Video.new()
	err = video_data.open_video(a_path, a_load_audio)
	if err:
		printerr("Something went wrong opening video file!", err)
		return false
	return true


func get_video_frame(a_is_playing: bool) -> ImageTexture:
	if frame_skip < 0 or frame_skip > 8 or (!a_is_playing and frame_skip > 8):
		video_frame_nr = current_frame
		return ImageTexture.create_from_image(video_data.seek_frame(current_frame))
	else:
		for l_i: int in frame_skip:
			if l_i + 1 == frame_skip:
				video_frame_nr = current_frame
				return ImageTexture.create_from_image(video_data.next_frame())
			video_data.next_frame()
	printerr("Something went wrong fetching video frame")
	return null


func next_frame_available(a_frame_nr: int, a_clip: ClipData) -> bool: # Only for video
	# Convert frame number to what frame number would be for the video file
	a_frame_nr = int(a_frame_nr / Project.frame_rate * video_data.get_framerate())
	current_frame = round(a_frame_nr - a_clip.pts - a_clip.frame_start / Project.frame_rate * video_data.get_framerate())
	if current_frame != video_frame_nr:
		frame_skip = -1 if current_frame < video_frame_nr else current_frame - video_frame_nr
		return true
	frame_skip = -1
	return false


func get_total_frame_nr() -> int:
	return video_data.get_total_frame_nr()


func get_framerate() -> float:
	return video_data.get_framerate()


func get_audio() -> AudioStream:
	return video_data.get_audio()
