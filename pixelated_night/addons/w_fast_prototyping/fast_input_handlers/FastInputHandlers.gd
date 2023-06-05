extends Node2D
class_name FastPrototyping

func _unhandled_input( event : InputEvent ) -> void :
	if self.is_visible_in_tree() :
		if event.is_action_pressed( "ui_cancel" ) :
			get_tree().quit()
