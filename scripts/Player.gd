extends CharacterBody2D

enum weapons {MELEE, RANGED}

const MAXSPEED : float = 400
const ACCELFRAMES : int = 5
const DASHWAIT : float = 1.5
const DASHIMMUNITY : float = 0.3
const DAMAGETIME : float = 1

var hue : float
var direction : Vector2 = Vector2.ZERO
var dashCooldown : float = 0
var dash : bool = false
var currentWeapon : int = weapons.RANGED
var health : int = 6
var invulnerability : float = 0
var resetting : bool

var explosionScene : PackedScene = preload("res://scenes/explosion.tscn")
@onready var game : Node2D = get_parent()
@onready var sprite : Sprite2D = get_node("Character/CharacterSprite")
@onready var hitbox : Area2D = get_node("Hitbox")
@onready var cooldownSprite : AnimatedSprite2D = get_node("Cooldown/CooldownSprite")
@onready var dashParticles : CPUParticles2D = get_node("DashParticles")

func _ready():
	cooldownSprite.speed_scale = 1 / DASHWAIT
	currentWeapon = $"/root/GlobalWindow".weapon
	hue = $"/root/GlobalWindow".hue

func _physics_process(delta : float) -> void:
	if not resetting:
		direction = game.unit_circle(Input.get_vector("left", "right", "up", "down"))
		velocity.x = direction.x * MAXSPEED
		velocity.y = direction.y * MAXSPEED
	else:
		velocity = Vector2.ZERO
	
	if dash and dashCooldown <= 0:
		if velocity.length() == 0:
			velocity.y = -MAXSPEED
		velocity *= 12
		dashParticles.emitting = true
		dashParticles.direction = -game.unit_circle(velocity)
		dashCooldown = DASHWAIT
		cooldownSprite.play("default")
	else:
		velocity = lerp(get_real_velocity(), velocity, (1.0 / ACCELFRAMES))
	dash = false
	dashCooldown -= delta
	
	hitbox.get_node("CollisionShape2D").disabled = dashCooldown > DASHWAIT - DASHIMMUNITY
	
	move_and_slide()
	
	invulnerability -= delta
	if invulnerability <= 0:
		for i in range(len(hitbox.get_overlapping_bodies())):
			var collision = hitbox.get_overlapping_bodies()[i]
			if collision.is_in_group("enemies"):
				collision.frozen = true
				collision.get_node("Timer").start()
			damage(1)
			break
	
	sprite.visible = invulnerability <= 0 or int(invulnerability * 12) % 2 == 1
	
	if health <= 0 and not resetting:
		game.get_node("AudioStreamPlayer").stream = load("res://assets/audio/sounds/death.mp3")
		game.get_node("AudioStreamPlayer").play()
		resetting = true
		get_node("DeathTimer").start()
		visible = false
		var explosion = explosionScene.instantiate()
		explosion.global_position = global_position
		explosion.scale = Vector2(1.5, 1.5)
		game.add_child(explosion)
		game.totalScore += game.score
	
	sprite.material.set_shader_parameter("shift_hue", hue)
	sprite.get_node("Hand0").material.set_shader_parameter("shift_hue", hue)
	sprite.get_node("Hand1").material.set_shader_parameter("shift_hue", hue)

func _input(event : InputEvent):
	if not resetting:
		if event.is_action_pressed("dash"):
			dash = true

func damage(value : int) -> void:
	if invulnerability <= 0:
		get_node("Character/Weapon").combo = 0
		health -= value
		invulnerability = DAMAGETIME

func _on_death_timer_timeout():
	game.get_node("AudioStreamPlayer").stop()
	game.get_node("GameCamera/Results").dead()
