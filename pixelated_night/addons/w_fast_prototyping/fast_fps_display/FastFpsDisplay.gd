extends ColorRect
class_name FastFpsDisplay

@onready var f_label : Label = $Label

func _process( delta : float ) -> void:
	f_label.text = 'FPS : ' + str( Engine.get_frames_per_second() )
