extends Control

const TRANSITIONSPEED : float = 0.15

var new_run : bool
var weapon : int
var hue : float

var settingsScene : PackedScene = preload("res://scenes/settings.tscn")
@onready var audioPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var timer : Timer = get_node("Timer")
@onready var transition : Timer = get_node("TransitionTimer")
@onready var colorRect : ColorRect = get_node("ColorRect")
@onready var foreground : Control = get_node("Foreground")
@onready var sprite : TextureRect = get_node("Foreground/Hue/TextureRect")

func _ready():
	get_node("Background").texture = load("res://assets/textures/ui/title/screenshots/" + str(randi_range(0, 7)) + ".png")
	get_node("Foreground/BestRun/Number").text = str($"/root/GlobalWindow".bestRun)
	sprite.set_material(sprite.get_material().duplicate(true))

func _process(delta):
	if timer.is_stopped():
		colorRect.color.a = lerp(colorRect.color.a, 0.0, 0.02)
		if new_run:
			foreground.position = lerp(foreground.position, Vector2(0, -648), TRANSITIONSPEED)
		else:
			foreground.position = lerp(foreground.position, Vector2.ZERO, TRANSITIONSPEED)
	else:
		foreground.position = Vector2(0, (timer.time_left ** 2) * 1000)
	sprite.material.set_shader_parameter("shift_hue", hue)

func _input(event):
	if event.is_action_pressed("back") and new_run:
		transition.start()
		set_buttons_disable(true)
		new_run = false

func _on_play_pressed():
	transition.start()
	set_buttons_disable(true)
	new_run = true

func _on_settings_pressed():
	var settings = settingsScene.instantiate()
	add_child(settings)

func _on_quit_pressed():
	get_tree().quit()

func _on_timer_timeout():
	audioPlayer.play()
	audioPlayer.stream.loop = true
	colorRect.color = Color.GAINSBORO
	set_buttons_disable(false)

func _on_transition_timer_timeout():
	set_buttons_disable(false)

func _on_start_pressed():
	$"/root/GlobalWindow".weapon = weapon
	$"/root/GlobalWindow".hue = hue
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_weapon_selected(index):
	weapon = index
	$"/root/GlobalWindow".get_node("ButtonSoundPlayer").play()

func _on_hue_slider_value_changed(value):
	hue = value
	$"/root/GlobalWindow".get_node("ScrollSoundPlayer").play()

func _on_background_timer_timeout():
	get_node("Background").texture = load("res://assets/textures/ui/title/screenshots/" + str(randi_range(0, 7)) + ".png")

func set_buttons_disable(value : bool):
	for group in foreground.get_node("Buttons").get_children():
		if group is Button:
			group.disabled = value
		else:
			for button in group.get_children():
				button.disabled = value
