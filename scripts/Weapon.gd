extends Area2D

const SWINGWAIT : float = 0.25
const HANDSPEED : float = 0.3

var cooldown : float = 0
var meleeMultiplier : float
var combo : int
var hand : int = 0

var projectile_scene : PackedScene = preload("res://scenes/projectile.tscn")
@onready var projectileSpawn : Node2D = get_node("ProjectileSpawn")
@onready var player : CharacterBody2D  = get_parent().get_parent()
@onready var hand0 : Sprite2D = player.get_node("Character/CharacterSprite/Hand0")
@onready var hand1 : Sprite2D = player.get_node("Character/CharacterSprite/Hand1")
@onready var game : Node2D = player.get_parent()
@onready var sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var hitbox : CollisionPolygon2D = get_node("CollisionPolygon2D")
@onready var timer : Timer = get_node("Timer")
@onready var overlay : Camera2D = get_parent().get_parent().get_parent().get_node("GameCamera")

func _ready():
	hitbox.disabled = true
	sprite.speed_scale = 0.25 / timer.wait_time

func _process(delta):
	cooldown -= delta
	if player.currentWeapon == player.weapons.MELEE:
		sprite.animation = "melee"
		sprite.position.x = 0
		if sprite.scale.x > 0:
			hand0.offset = lerp(hand0.offset, Vector2(12, -20), HANDSPEED)
			hand1.offset = lerp(hand1.offset, Vector2(-15, -9), HANDSPEED)
		else:
			hand0.offset = lerp(hand0.offset, Vector2(-15, -9), HANDSPEED)
			hand1.offset = lerp(hand1.offset, Vector2(12, -20), HANDSPEED)
	elif player.currentWeapon == player.weapons.RANGED:
		sprite.animation = "ranged"
		sprite.scale = sprite.scale.abs()
		sprite.position.x = -28
		hand0.offset = lerp(hand0.offset, hand0.get_meta("default"), HANDSPEED)
		hand1.offset = lerp(hand1.offset, hand1.get_meta("default"), HANDSPEED)
		
	if timer.time_left > 0:
		if sprite.scale.x > 0:
			sprite.rotation_degrees = (90 * (1 - (((1 / timer.wait_time) * timer.time_left) ** 2))) -90
		else:
			sprite.rotation_degrees = 90 - (90 * (1 - (((1 / timer.wait_time) * timer.time_left) ** 2)))

func _input(event : InputEvent):
	if event.is_action_pressed("attack"):
		if player.currentWeapon == player.weapons.MELEE and cooldown <= 0:
			hitbox.disabled = false
			timer.start()
			cooldown = SWINGWAIT
			sprite.play("melee")
			sprite.scale.x = - sprite.scale.x
			meleeMultiplier = accuracy_multiplier()
		elif player.currentWeapon == player.weapons.RANGED:
			if hand == 0:
				hand0.offset = Vector2(-9, -15)
				hand = 1
			else:
				hand1.offset = Vector2(-9, -15)
				hand = 0
			var projectile = projectile_scene.instantiate()
			projectile.global_position = projectileSpawn.global_position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
			projectile.direction = (get_global_mouse_position() - projectile.global_position).normalized()
			projectile.speed = 15
			projectile.friendly = true
			projectile.texture = "note"
			projectile.hue = randf()
			projectile.damage = accuracy_multiplier()
			game.add_child(projectile)

func _on_timer_timeout():
	hitbox.disabled = true

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.damage(2 * meleeMultiplier)

func accuracy_multiplier() -> float:
	if abs(game.nearestBeat) < game.tpb / 12:
		overlay.score(game.rank.EXCELLENT)
		game.excellents += 1
		combo += 1
		if combo >= 16:
			return 2
		else:
			return 1
	elif abs(game.nearestBeat) < 2 * (game.tpb / 12):
		overlay.score(game.rank.GREAT)
		if combo >= 16:
			return 1.5
		else:
			return 0.75
	elif abs(game.nearestBeat) < 3 * (game.tpb / 12):
		overlay.score(game.rank.GOOD)
		combo = 0
		return 0.5
	elif abs(game.nearestBeat) < 4 * (game.tpb / 12):
		overlay.score(game.rank.OK)
		combo = 0
		return 0.25
	else:
		overlay.score(game.rank.MISS)
		combo = 0
		return 0
