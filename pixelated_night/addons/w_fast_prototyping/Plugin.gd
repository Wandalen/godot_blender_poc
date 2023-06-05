@tool
extends EditorPlugin

func _enter_tree() -> void :
	print( '_enter_tree' )
	# Initialization of the plugin goes here.
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	print( '_exit_tree' )
	pass
