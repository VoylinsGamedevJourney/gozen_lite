extends Node


func _input(a_event: InputEvent) -> void:
	# Project autoload events
	if a_event.is_action_pressed("project_save"):
		Project.save_project()

