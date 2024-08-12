extends Node


var action_current: int = -1
var actions: Array = []



func _input(a_event: InputEvent) -> void:
	if a_event.is_action_pressed("ui_undo"):
		undo_action()
	if a_event.is_action_pressed("ui_redo"):
		redo_action()


	# Project autoload events
	if a_event.is_action_pressed("project_save"):
		Project.save_project(Project._path)
	if a_event.is_action_pressed("project_new_save"):
		Project.save_project()
	# TODO: Make a popup handler for open_project, save_project, and load_project
	#if a_event.is_action_pressed("project_open"):
	#	Project.open_project()
	if a_event.is_action_pressed("project_new"):
		# TODO: show popup message to agree and possibly save unsaved changes
		Project.reset()
	if a_event.is_action_pressed("open_render_menu"):
		print("Not implemented yet!")

	# Help stuff
	if a_event.is_action_pressed("close_editor"):
		print("Not implemented yet!")

	# Editor stuff
	if a_event.is_action_pressed("open_help"):
		print("Not implemented yet!")

	# Timeline stuff
	if a_event.is_action_pressed("delete") and Clip.selected_clips.size() != 0:
		for l_clip: PanelContainer in Clip.selected_clips:
			Project.remove_clip(l_clip.id)
			l_clip.queue_free()
			await RenderingServer.frame_post_draw
		

func undo_action() -> void:
	if actions.size() != 0:
		var l_action: Action = actions[action_current]
		l_action.undo_function.call(l_action.undo_args)
		if action_current > 0:
			action_current -= 1 


func redo_action() -> void:
	if actions.size() >= action_current:
		action_current += 1 
		var l_action: Action = actions[action_current]
		l_action.function.call(l_action.do_args)


func do(a_function: Callable, a_undo_function: Callable, a_do_args: Array = [], a_undo_args: Array = []) -> void:
	var l_action: Action = Action.new(a_function, a_undo_function, a_do_args, a_undo_args)
	a_function.call(a_do_args)
	if actions.size() == Settings.actions_max:
		actions.pop_front()
		actions.append(l_action)
		return
	elif actions.size() != action_current:
		actions.resize(action_current + 1)
	action_current += 1
	actions.append(l_action)



class Action:
	var function: Callable
	var undo_function: Callable
	var do_args: Array
	var undo_args: Array
	
	func _init(
			a_function: Callable, a_undo_function: Callable, 
			a_do_args: Array = [], a_undo_args: Array = []) -> void:
		function = a_function
		undo_function = a_undo_function
		do_args = a_do_args
		undo_args = a_undo_args
