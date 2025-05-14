extends Control

func _ready():
	get_node("MarginContainer/TabContainer/Graphics/VBoxContainer/FPS/MarginContainer/HBoxContainer/VBoxContainer2/TextEdit").text = str(Engine.max_fps)

func _process(delta):
	get_node("MarginContainer/TabContainer/Graphics/VBoxContainer/Fullscreen/MarginContainer/HBoxContainer/VBoxContainer2/CheckButton").button_pressed = $"/root/GlobalWindow".fullscreen

func _input(event):
	if event.is_action_pressed("back"):
		queue_free()

func _on_master_slider_changed(value):
	$"/root/GlobalWindow".get_node("ScrollSoundPlayer").play()
	AudioServer.set_bus_volume_db(0, value)
	if value == -20:
		AudioServer.set_bus_volume_db(0, -100)


func _on_mute_button_toggled(toggled_on):
	AudioServer.set_bus_mute(0, toggled_on)


func _on_fullscreen_button_toggled():
	$"/root/GlobalWindow".toggle_fullscreen()


func _on_fps_text_set():
	Engine.max_fps = int(get_node("MarginContainer/TabContainer/Graphics/VBoxContainer/FPS/MarginContainer/HBoxContainer/VBoxContainer2/TextEdit").text)


func _on_tab_container_tab_changed(tab):
	$"/root/GlobalWindow".get_node("ButtonSoundPlayer").play()
