class_name Timeline extends PanelContainer


const TIMELINE_PADDING: int = 2000


static var is_clip_being_moved: bool = false
static var is_playhead_being_moved: bool = false

var end_frame_pts: int = 0
var pre_zoom: Array = [0,0,0] # local mouse position, scroll position, previous timeline_scale



func _ready() -> void:
	Project._on_project_loaded.connect(load_project)
	Project._update_timeline.connect(update_timeline)
	Project._on_end_frame_pts_changed.connect(func(a_value): end_frame_pts = a_value)

	load_defaults()
	_set_pre_zoom()
	update_timeline()


func _process(_delta: float) -> void:
	if is_playhead_being_moved and !is_clip_being_moved:
		var l_temp: float = %TimelineBox.get_local_mouse_position().x

		if l_temp < 0:
			l_temp = 0.0

		%Playhead.position.x = snappedf(l_temp, Project.timeline_scale)- Project.timeline_scale
		if %Playhead.position.x < 0:
			%Playhead.position.x = 0

		Project._playhead_moved.emit(true)


#------------------------------------------------ PROJECT FUNCTIONS
func load_defaults() -> void:
	_reset()
	for _i: int in Settings.default_tracks:
		add_track(_i)


func load_project() -> void:
	_reset()
	for _i: int in Project.tracks.size():
		add_track(_i)
	
	for l_track: int in Project.tracks.size():
		for l_clip_pts: int in Project.tracks[l_track]:
			%TimelineBox.add_new_clip(Project.tracks[l_track][l_clip_pts])


func _reset() -> void:
	for l_clip: Control in %TimelineBox.get_children():
		if not l_clip.name in [StringName("Playhead"), StringName("_ClipPreview")]:
			l_clip.free()

	for l_header: PanelContainer in %TimelineSideVBox.get_children():
		l_header.free()

	await RenderingServer.frame_pre_draw


#------------------------------------------------ INPUT FUNCTIONS
func _on_timeline_box_gui_input(a_event:InputEvent) -> void:
	if a_event is InputEventMouseButton:
		if a_event.button_index == MOUSE_BUTTON_LEFT:
			if a_event.is_released():
				is_playhead_being_moved = false
				Project._playhead_moved.emit(false)
			elif a_event.is_pressed():
				is_playhead_being_moved = true
	
	if a_event.is_action_released("timeline_zoom_in", true):# and a_event.ctrl_pressed:
		get_viewport().set_input_as_handled()
		_set_pre_zoom()
		if Settings.timeline_scale_max > Project.timeline_scale:
			Project.timeline_scale += 0.05
		update_timeline()
	elif a_event.is_action_released("timeline_zoom_out", true):# and a_event.ctrl_pressed:
		get_viewport().set_input_as_handled()
		_set_pre_zoom()
		if Settings.timeline_scale_min < Project.timeline_scale:
			Project.timeline_scale -= 0.05
		update_timeline()


func _on_main_timeline_scroll_gui_input(a_event:InputEvent) -> void:
	if a_event.ctrl_pressed:
		get_viewport().set_input_as_handled()


func _on_side_panel_resized():
	$VBox/TopHBox/Left.custom_minimum_size.x = $VBox/BottomHBox/SidePanel.size.x


#------------------------------------------------ TIMELINE HANDLING FUNCTIONS
func _set_pre_zoom() -> void:
	pre_zoom[0] = %TimelineBox.get_local_mouse_position().x
	pre_zoom[1] = %MainTimelineScroll.scroll_horizontal
	pre_zoom[2] = Project.timeline_scale


func update_timeline() -> void:
	if pre_zoom[2] == 0:
		printerr("pre_zoom 2 is empty!!")
		print(get_stack())
		return
	if pre_zoom[2] != Project.timeline_scale:
		Project.set_timeline_scale(Project.timeline_scale)

	# Resizing the timeline
	if (Project.get_end_frame_pts() + TIMELINE_PADDING) * Project.timeline_scale < %MainTimelineScroll.size.x:
		%TimelineBox.custom_minimum_size.x = %MainTimelineScroll.size.x
	else:
		%TimelineBox.custom_minimum_size.x = (Project.get_end_frame_pts() + TIMELINE_PADDING) * Project.timeline_scale

	# Setting the scroll_horizontal correct
	if %MainTimelineScroll.scroll_horizontal != 0: 
		var l_scroll_offset: int = pre_zoom[0] - pre_zoom[1]
		var l_new_scroll: int = roundi(roundi(pre_zoom[0] / pre_zoom[2]) * Project.timeline_scale)
		%MainTimelineScroll.scroll_horizontal = abs(l_new_scroll - l_scroll_offset) # (pre_zoom[1]/pre_zoom[2]*timeline_scale)#-(pre_zoom[0]-pre_zoom[1])

	# Changing playhead to correct position
	if %Playhead.position.x != 0 and pre_zoom[2] != 0:
		%Playhead.position.x = %Playhead.position.x / pre_zoom[2] * Project.timeline_scale


#------------------------------------------------ TRACK HANDLING FUNCTIONS
func add_track(a_id: int) -> void:
	%TimelineSideVBox.add_child(_create_header())
	var l_line: ColorRect = ColorRect.new()

	l_line.name = "_line%s" % a_id
	l_line.custom_minimum_size.y = 3
	l_line.anchor_right = ANCHOR_END
	l_line.position.y = (a_id + 1) * Project.track_size - l_line.custom_minimum_size.y
	l_line.color = Color8(80, 44, 115, 105)
	l_line.mouse_filter = Control.MOUSE_FILTER_IGNORE

	%TimelineBox.add_child(l_line)


func _create_header() -> PanelContainer:
	var l_panel: PanelContainer = PanelContainer.new()
	var l_hbox: HBoxContainer = HBoxContainer.new()
	var l_button_visible: Button = Button.new()	

	l_button_visible.custom_minimum_size = Vector2i(28,0)
	l_button_visible.expand_icon = true
	l_button_visible.flat = true

	var l_button_mute: Button = l_button_visible.duplicate()
	var l_button_lock: Button = l_button_visible.duplicate()	
	l_button_visible.icon = preload("res://icons/visible.png")
	l_button_mute.icon = preload("res://icons/music_note.png")
	l_button_lock.icon = preload("res://icons/lock_open.png")
	l_panel.custom_minimum_size = Vector2(0, Project.track_size)

	l_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l_panel.add_theme_stylebox_override("panel", preload("res://resources/track_header.tres"))
	l_hbox.add_child(l_button_visible)
	l_hbox.add_child(l_button_mute)
	l_hbox.add_child(l_button_lock)
	l_panel.add_child(l_hbox)

	return l_panel




