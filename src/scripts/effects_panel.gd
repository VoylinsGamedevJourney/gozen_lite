class_name EffectsPanel extends PanelContainer


# We want file effects and clip effects, so we will need to change the content
# of this panel depending on what has been selected

static var instance: EffectsPanel


func _ready() -> void:
	instance = self


static func show_file_effects(a_file_id: int) -> void:
	# Already connected to file buttons!
	pass #print(a_file_id)

