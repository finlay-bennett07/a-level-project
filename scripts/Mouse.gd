extends Node

var cursor : CompressedTexture2D = load("res://assets/textures/ui/cursor.png")
var reticle : CompressedTexture2D = load("res://assets/textures/ui/reticle.png")

func _process(_delta):	
	if get_parent().get_parent().get_child(-1) is Control or get_tree().paused:
		Input.set_custom_mouse_cursor(cursor)
	else:
		Input.set_custom_mouse_cursor(reticle, Input.CURSOR_ARROW, Vector2(24, 24))
