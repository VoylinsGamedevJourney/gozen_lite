class_name ViewPanel extends PanelContainer


static var instance: ViewPanel

var end_timepoint: int = 0
var is_playing: bool = false
var was_playing: bool = false

var time_elapsed: float = 0.0
var is_dragging: bool = false

var views: Array[CanvasLayer] = []
var current_clips: Array[Clip] = []

var current_frame: int = -1



func _ready() -> void:
	instance = self
	Project._on_project_loaded.connect(func() -> void:
			views = []
			current_clips = []
			set_frame()
			%ViewSubViewport.size = Project.resolution)
	for l_id: int in Project.tracks.size():
		add_view()
	%ViewSubViewport.size = Project.resolution
	
		
func _input(a_event: InputEvent) -> void:
	if a_event.is_action_pressed("play"):
		_on_play_pause_button_pressed()
		

func _process(a_delta: float) -> void:
	if is_playing:
		time_elapsed += a_delta
		if time_elapsed < 1./Project.frame_rate:
			return
		
		while time_elapsed >= 1./Project.frame_rate:
			time_elapsed -= 1./Project.frame_rate
			%Playhead.position.x += Timeline.instance.timeline_scale
		
		if get_current_frame_nr() >= Project.get_end_frame_timepoint(): # TODO: have this as a value which updates when needed inside of Project
			if is_dragging:
				return
			is_playing = !is_playing
		else:
			set_frame()


func get_current_frame_nr() -> int:
	return roundi(%Playhead.position.x / Timeline.instance.timeline_scale)


func _on_play_pause_button_pressed():
	# Checking if enough views are present
	while(views.size() != Project.tracks.size()):
		if views.size() > Project.tracks.size():
			remove_view()
		else: 
			add_view()
	is_playing = !is_playing
	time_elapsed = 0.


func _on_forward_button_pressed():
	pass # TODO: Replace with function body.


func _on_rewind_button_pressed():
	pass # TODO: Replace with function body.


func add_view() -> void:
	var l_id: int = views.size()
	views.append(CanvasLayer.new())
	views[l_id].add_child(TextureRect.new())
	views[l_id].get_child(0).material = preload("res://resources/master_shader_material.tres") # Not certain if effects will be the same for all clips
	%ViewSubViewport.add_child(views[l_id])
	for l_canvas_id: int in views.size():
		views[l_canvas_id].layer = l_id - l_canvas_id
	current_clips.append(null)


func remove_view() -> void:
	# TODO: Add an integer so a specific view can be removed + add line which also removes the view	
	views.pop_back()
	current_clips.pop_back()


func set_frame(a_frame_nr: int = get_current_frame_nr()) -> void:
	if current_frame == a_frame_nr:
		return
	current_frame = a_frame_nr
	for l_track_id: int in Project.tracks.size():
		if a_frame_nr in Timeline.instance.get_track_raw_data(l_track_id):
			# Check if clip is loaded
			if current_clips[l_track_id] == null: # Find which clip is there
				current_clips[l_track_id] = get_clip_from_raw(l_track_id, a_frame_nr)
				current_clips[l_track_id].current_frame = -1

			var l_type: int = Project.file_data[current_clips[l_track_id].file_id].type
			var l_image: Image
			if l_type == File.VIDEO:
				if current_clips[l_track_id].next_frame_available(a_frame_nr):
					l_image = current_clips[l_track_id].get_video_frame(is_playing)
					if l_image != null:
						views[l_track_id].get_child(0).texture = ImageTexture.create_from_image(l_image)
			elif l_type == File.IMAGE:
				views[l_track_id].get_child(0).texture = ImageTexture.create_from_image(current_clips[l_track_id].get_image())
			else:
				print("Not implemented yet")
		else:
			# Clear previous frame
			views[l_track_id].get_child(0).texture = null
			current_clips[l_track_id] = null
		

func get_clip_from_raw(a_track_id: int, a_frame_nr: int) -> Clip:
	for l_i: int in range(a_frame_nr):
		if Project.tracks[a_track_id].has(a_frame_nr - l_i):
			return Project.clips[Project.tracks[a_track_id][a_frame_nr - l_i]]
	return null



func playhead_moved(_dragging: bool) -> void:
	# Have some performance stuff for when dragging
	set_frame()

