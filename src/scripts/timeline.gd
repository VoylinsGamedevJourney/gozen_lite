extends PanelContainer

var video_tracks: Array = []
var audio_tracks: Array = []


func _ready() -> void:
	load_defaults()


func load_defaults() -> void:
	_reset()
	for _i: int in Settings.default_video_tracks:
		add_video_track()
		Project.tracks_video.append({})
	for _i: int in Settings.default_audio_tracks:
		add_audio_track()
		Project.tracks_audio.append({})


func load_project() -> void:
	_reset()
	for _i: int in Project.tracks_video.size():
		add_video_track()
		Project.tracks_video.append({})
	for _i: int in Project.tracks_audio.size():
		add_audio_track()
		Project.tracks_audio.append({})
	


func _reset() -> void:
	for l_track: Control in video_tracks:
		l_track.queue_free()
	for l_track: Control in audio_tracks:
		l_track.queue_free()
	video_tracks = []
	audio_tracks = []
	Project.tracks_video = []
	Project.tracks_audio = []


func add_video_track() -> void:
	# Add header
	var l_video_track_header: PanelContainer =_create_header("V%s" % str(video_tracks.size() + 1))
	%TimelineSideVBox.add_child(l_video_track_header)
	%TimelineSideVBox.move_child(l_video_track_header, 0)
	# Add line
	var l_video_track: Control = _create_track()
	video_tracks.append(l_video_track)
	%TimelineMainVBox.add_child(l_video_track)
	%TimelineMainVBox.move_child(l_video_track, 0)


func add_audio_track() -> void:
	# Add header
	%TimelineSideVBox.add_child(_create_header("A%s" % str(audio_tracks.size() + 1)))
	# Add line
	var l_audio_track: Control = _create_track()
	audio_tracks.append(l_audio_track)
	%TimelineMainVBox.add_child(l_audio_track)


func _create_header(a_label_text: String) -> PanelContainer:
	var l_panel: PanelContainer = PanelContainer.new()
	var l_label: Label = Label.new()
	l_label.text = a_label_text
	l_panel.custom_minimum_size = Vector2(0, 20)
	l_panel.add_child(l_label)
	return l_panel


func _create_track() -> Control:
	var l_control: Control = Control.new()
	l_control.custom_minimum_size = Vector2(0, 20)
	return l_control
