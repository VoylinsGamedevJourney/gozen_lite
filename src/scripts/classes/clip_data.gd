class_name ClipData extends Node
# Clip Data
#
# This is just a data class

var id: int
var file_id: int
var pts: int = 0 # Presentation timestamp: Start frame of the clip
var duration: int = 0
var frame_start: int = 0 # For video and audio clips
var frame_end: int = 0 # For video and audio clips

