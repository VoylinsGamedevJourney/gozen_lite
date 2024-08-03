class_name ViewPanel extends PanelContainer


static var instance: ViewPanel

var end_timepoint: int = 0
var is_playing: bool = false
var was_playing: bool = false

var time_elapsed: float = 0.0
var is_dragging: bool = false
var previous_drag_time: int = 0

var views: Array[TextureRect] = []
var current_clips: Array[ClipData] = []

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
		
		if get_current_frame_nr() >= Project.get_end_frame_timepoint():
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
	views.append(TextureRect.new())
	views[l_id].material = preload("res://resources/master_shader_material.tres") # Not certain if effects will be the same for all clips
	%ViewSubViewport.add_child(views[l_id])
	%ViewSubViewport.move_child(views[l_id], 0)
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

			var l_type: int = Project.file_data[current_clips[l_track_id].file_id].type
			if l_type == File.VIDEO:
				_set_video_clip_frame(l_track_id, a_frame_nr)
			elif l_type == File.IMAGE:
				_set_image_clip_frame(l_track_id)
			elif l_type == File.COLOR:
				_set_color_clip_frame(l_track_id)
		else:
			# Clear previous frame
			views[l_track_id].texture = null
			current_clips[l_track_id] = null


func _set_video_clip_frame(a_track_id: int, a_frame_nr: int) -> void:
	if Project._file_data[current_clips[a_track_id].file_id][a_track_id].next_frame_available(
		a_frame_nr, current_clips[a_track_id]) or views[a_track_id].texture == null: 
		views[a_track_id].texture = Project._file_data[current_clips[a_track_id].file_id][a_track_id].get_video_frame(is_playing)


func _set_image_clip_frame(a_track_id: int) -> void:
	views[a_track_id].texture = Project._file_data[current_clips[a_track_id].file_id]


func _set_color_clip_frame(a_track_id: int) -> void:
	# TODO: Use a gradient and just set both colors to the same?
	views[a_track_id].texture = Project._file_data[current_clips[a_track_id].file_id]
		

func get_clip_from_raw(a_track_id: int, a_frame_nr: int) -> ClipData:
	for l_i: int in range(a_frame_nr):
		if Project.tracks[a_track_id].has(a_frame_nr - l_i):
			return Project.clips[Project.tracks[a_track_id][a_frame_nr - l_i]]
	return null



func playhead_moved(a_dragging: bool) -> void:
	# Have some performance stuff for when dragging
	if !is_dragging and a_dragging:
		is_dragging = a_dragging
		was_playing = is_playing
		is_playing = false
	if abs(abs(get_current_frame_nr())-abs(current_frame)) < 20 or previous_drag_time + 100 <= Time.get_ticks_msec():
		previous_drag_time = Time.get_ticks_msec()
		set_frame()
	if !a_dragging:
		is_dragging = false
		is_playing = was_playing

