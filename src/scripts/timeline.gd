class_name Timeline extends PanelContainer


signal _scale_changed()

static var instance: Timeline
static var timeline_scale: float = 1. # One frame is a pixel in this scale

static var timeline_scale_max: float = 5.6
static var timeline_scale_min: float = 0.1

var is_dragging: bool = false
var pre_zoom: Array = [0,0,0] # local mouse position, scroll position, previous timeline_scale



func _ready() -> void:
	instance = self
	load_defaults()
	call_deferred("update_timeline")


func _process(_delta: float) -> void:
	if is_dragging:
		var l_temp: float = %TimelineMainVBox.get_local_mouse_position().x
		if l_temp < 0:
			l_temp = 0.0
		%Playhead.position.x = snappedf(l_temp, timeline_scale)- timeline_scale
		ViewPanel.instance.playhead_moved(true)


func _on_timeline_main_v_box_gui_input(a_event:InputEvent) -> void:
	if a_event is InputEventMouseButton:
		if a_event.button_index == MOUSE_BUTTON_LEFT:
			if a_event.is_released():
				is_dragging = false
				ViewPanel.instance.playhead_moved(false)
			elif a_event.is_pressed():
				is_dragging = true
	
	# TODO: Make the scroll of the timeline work according to where the mouse is located
	if a_event.is_action_released("timeline_zoom_in", true):# and a_event.ctrl_pressed:
		get_viewport().set_input_as_handled()
		_set_pre_zoom()
		if timeline_scale_max > timeline_scale:
			timeline_scale += 0.05
		update_timeline()
	elif a_event.is_action_released("timeline_zoom_out", true):# and a_event.ctrl_pressed:
		get_viewport().set_input_as_handled()
		_set_pre_zoom()
		if timeline_scale_min < timeline_scale:
			timeline_scale -= 0.05
		update_timeline()


func _set_pre_zoom() -> void:
	pre_zoom[0] = get_local_mouse_position().x
	pre_zoom[1] = %MainTimelineScroll.scroll_horizontal
	pre_zoom[2] = timeline_scale


func update_timeline() -> void:
	timeline_scale = clampf(timeline_scale, timeline_scale_min, timeline_scale_max)
	if (Project.get_end_frame_timepoint() + 8000) * timeline_scale < %MainTimelineScroll.size.x:
		%TimelineMainVBox.get_parent().size.x = %MainTimelineScroll.size.x
		%TimelineMainVBox.get_parent().custom_minimum_size.x = %MainTimelineScroll.size.x
	else:
		%TimelineMainVBox.get_parent().size.x = (Project.get_end_frame_timepoint() + 8000) * timeline_scale
		%TimelineMainVBox.get_parent().custom_minimum_size.x = (Project.get_end_frame_timepoint() + 8000) * timeline_scale
	if %Playhead.position.x != 0:
		%Playhead.position.x = %Playhead.position.x/pre_zoom[2]*timeline_scale
	if pre_zoom[1] == 0:
		%MainTimelineScroll.scroll_horizontal = 0
	else:
		%MainTimelineScroll.scroll_horizontal =	((pre_zoom[0]/pre_zoom[2])*timeline_scale)-(pre_zoom[0]-pre_zoom[1])
	_scale_changed.emit()


func load_defaults() -> void:
	_reset()
	for _i: int in Settings.default_tracks:
		add_track()


func load_project() -> void:
	_reset()
	for _i: int in Project.tracks.size():
		add_track()
		%TimelineMainVBox.get_child(_i).load_project()


func _reset() -> void:
	for l_track: Control in %TimelineMainVBox.get_children():
		if l_track.name != StringName("Playhead"):
			l_track.free()
	for l_header: PanelContainer in %TimelineSideVBox.get_children():
		l_header.free()
	# We need a certain amount of waiting time else it causes issues
	await RenderingServer.frame_pre_draw


func get_track_raw_data(a_id: int) -> PackedInt64Array:
	return %TimelineMainVBox.get_child(a_id)._track_range


func add_track() -> void:
	# Add header
	%TimelineSideVBox.add_child(_create_header())
	# Add line
	var l_track: Panel = Panel.new()
	l_track.custom_minimum_size = Vector2(0, 30)
	l_track.set_script(preload("res://scripts/classes/track.gd"))
	l_track.add_theme_stylebox_override("panel", preload("res://resources/track.tres"))
	l_track.mouse_filter = Control.MOUSE_FILTER_PASS
	%TimelineMainVBox.add_child(l_track)


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
	l_panel.custom_minimum_size = Vector2(0, 30)

	l_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l_panel.add_theme_stylebox_override("panel", preload("res://resources/track_header.tres"))
	l_hbox.add_child(l_button_visible)
	l_hbox.add_child(l_button_mute)
	l_hbox.add_child(l_button_lock)
	l_panel.add_child(l_hbox)
	return l_panel


func _on_main_timeline_scroll_gui_input(a_event:InputEvent) -> void:
	if a_event.ctrl_pressed:
		get_viewport().set_input_as_handled()

