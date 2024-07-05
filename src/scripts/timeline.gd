class_name Timeline extends PanelContainer



func _ready() -> void:
	load_defaults()


func load_defaults() -> void:
	_reset()
	for _i: int in Settings.default_tracks:
		add_track()
	


func load_project() -> void:
	_reset()
	for _i: int in Project.tracks.size():
		add_track()


func _reset() -> void:
	for l_track: Control in %TimelineMainVBox.get_children():
		l_track.queue_free()


func add_track() -> void:
	# Add header
	%TimelineSideVBox.add_child(_create_header("Track"))
	# Add line
	var l_track: Control = Control.new()
	l_track.custom_minimum_size = Vector2(0, 20)
	l_track.set_script(preload("res://scripts/classes/track.gd"))
	%TimelineMainVBox.add_child(l_track)


func _create_header(a_label_text: String) -> PanelContainer:
	var l_panel: PanelContainer = PanelContainer.new()
	var l_label: Label = Label.new()
	l_label.text = a_label_text
	l_panel.custom_minimum_size = Vector2(0, 20)
	l_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l_panel.add_child(l_label)
	return l_panel

