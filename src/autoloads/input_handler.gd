extends Node


func _input(a_event: InputEvent) -> void:
	# Project autoload events
	if a_event.is_action_pressed("project_save"):
		Project.save_project(Project._path)
	if a_event.is_action_pressed("project_new_save"):
		Project.save_project()
	if a_event.is_action_pressed("project_open"):
		Project.open_project()
	if a_event.is_action_pressed("project_new"):
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
			l_clip.get_parent().remove_clip_timedata(Project.clips[l_clip.clip_id])
			Project.remove_clip(l_clip.clip_id, l_clip.get_parent().get_index())
			l_clip.queue_free()
		
		
