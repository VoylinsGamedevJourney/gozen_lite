extends PanelContainer

var video_codecs: Array = []
var audio_codecs: Array = []



func _ready() -> void:
	var l_supported_codecs: Dictionary = Renderer.get_supported_codecs()
	for l_entry: String in l_supported_codecs.video:
		video_codecs.append(l_supported_codecs.video[l_entry].codec_id)
		if l_supported_codecs.video[l_entry].hardware_accel:
			%VideoCodecOptionButton.add_item(l_entry + '*')
		else:
			%VideoCodecOptionButton.add_item(l_entry)
		if !l_supported_codecs.video[l_entry].supported:
			%VideoCodecOptionButton.add_item(l_entry)


func _process(_delta) -> void:
	pass


func _on_close_button_pressed() -> void:
	# TODO: Check if rendering, when rendering we can't close this menu!
	self.visible = false

