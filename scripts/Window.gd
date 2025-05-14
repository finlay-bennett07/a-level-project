extends Node

var previousState = DisplayServer.WINDOW_MODE_WINDOWED
var fullscreen : bool = false
var weapon : int
var hue : float
var bestRun : int

func _process(_delta):
	fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if Engine.max_fps == 0:
		Engine.max_fps = 60
	
	var buttons : Array = get_tree().get_nodes_in_group("button")
	for b in buttons:
		var exists = false
		for c in b.get_signal_connection_list("pressed"):
			if c.callable == Callable(self, "_on_button_pressed()"):
				exists = true
				break
		if not exists:
			b.pressed.connect(_on_button_pressed.bind())

func _input(event):
	if event.is_action_pressed("hide_ui") and get_parent().get_children()[-1] is Node2D:
		get_parent().get_node("Game/GameCamera").visible = !get_parent().get_node("Game/GameCamera").visible
	elif event.is_action_pressed("fullscreen"):
		toggle_fullscreen()

func toggle_fullscreen():
	if fullscreen:
		DisplayServer.window_set_mode(previousState)
	else:
		previousState = DisplayServer.window_get_mode()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_button_pressed():
	get_node("ButtonSoundPlayer").play()
