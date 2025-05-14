extends CharacterBody2D

const DAMAGETIME : float = 0.2
const FIREWAIT : int = 2

var speed : int
var color : Color
var health : float
var invulnerability : float = 0.3
var frozen : bool = false
var type : int
var identifier : String
var cooldown : int

var explosionScene : PackedScene = preload("res://scenes/explosion.tscn")
var projectileScene : PackedScene = preload("res://scenes/projectile.tscn")
@onready var game : Node2D = get_parent()
@onready var player : CharacterBody2D = game.get_node("Player")
@onready var sprite : AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var nav : NavigationAgent2D = get_node("NavigationAgent2D")

func _ready():
	sprite.play(identifier)
	sprite.speed_scale = float(game.bpm) / 120.0

func _physics_process(delta):
	invulnerability -= delta
	if health <= 0:
		var explosion = explosionScene.instantiate()
		explosion.global_position = global_position
		explosion.color = color
		explosion.scale = Vector2(1.2, 1.2)
		game.add_child(explosion)
		game.score += 1
		game.get_node("GameCamera").kill()
		queue_free()

	sprite.visible = invulnerability <= 0 or int(invulnerability * 12) % 2 == 1
	
	if type == game.enemies.REDSLIME:
		nav.target_position = player.global_position
	elif type == game.enemies.BLUESLIME:
		if (global_position - player.global_position).length() < 400:
			nav.target_position = player.global_position + (game.unit_circle(global_position - player.global_position) * 380)
		else:
			nav.target_position = player.global_position
	else:
		nav.target_position = global_position
	
	if not frozen:
		move_and_slide()
	
	if type == game.enemies.BLUESLIME:
		velocity = game.unit_circle(nav.get_next_path_position() - global_position) * speed
	elif type == game.enemies.REDSLIME:
		velocity = lerp(velocity, Vector2.ZERO, 0.1)

func _on_timer_timeout():
	frozen = false

func damage(value : float) -> void:
	if invulnerability <= 0:
		health -= value
		invulnerability = DAMAGETIME

func beat():
	cooldown -= 1
	if type == game.enemies.BLUESLIME and cooldown <= 0:
		var projectile = projectileScene.instantiate()
		projectile.global_position = global_position
		projectile.direction = (player.global_position - global_position).normalized()
		projectile.speed = 8
		projectile.friendly = false
		projectile.texture = "blue_slime_ball"
		game.add_child(projectile)
		cooldown = FIREWAIT
	elif type == game.enemies.REDSLIME:
		velocity = game.unit_circle(nav.get_next_path_position() - global_position) * speed * 3
