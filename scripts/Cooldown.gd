extends Node2D

var player : CharacterBody2D
var sprite : AnimatedSprite2D

func _ready():
	player = get_parent()
	sprite = get_node("CooldownSprite")

func _process(delta):
	if player.dashCooldown > 0:
		sprite.visible = true
	else:
		sprite.visible = false
