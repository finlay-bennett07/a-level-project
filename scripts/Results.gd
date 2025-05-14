extends Control

@onready var game : Node2D = get_parent().get_parent()

func dead():
	visible = true
	if game.floor > $"/root/GlobalWindow".bestRun:
		$"/root/GlobalWindow".bestRun = game.floor 
	get_node("Stats/VBoxContainer/Kills").text = "Kills: " + str(game.totalScore)
	get_node("Stats/VBoxContainer/Floors").text = "Floors: " + str(game.floor)
	get_node("Stats/VBoxContainer/BestCombo").text = "Best Combo: " + str(game.bestCombo)
	get_node("Stats/VBoxContainer/Excellents").text = "Excellents: " + str(game.excellents)
	get_node("Stats/VBoxContainer/Time").text = "Time: " + str(int(game.totalTimeElapsed)) + "s"

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
