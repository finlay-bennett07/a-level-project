extends Control

var settings : bool = false
var paused : bool = false

var settingsScene : PackedScene = preload("res://scenes/settings.tscn")

func _process(_delta):
	get_tree().paused = paused
	visible = paused

func _input(event):
	if event.is_action_pressed("back") and not get_parent().get_parent().resetting:
		if paused and settings:
				settings = false
		else:
			paused = !paused

func _on_resume_pressed():
	paused = false

func _on_settings_pressed():
	add_child(settingsScene.instantiate())
	settings = true

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
