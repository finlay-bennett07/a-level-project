extends Area2D

var direction : Vector2
var speed : int
var friendly : bool
var texture : String
var hue : float
var damage : float

@onready var sprite : Sprite2D = get_node("Sprite2D")
@onready var game : Node2D = get_parent()

func _ready():
	if texture == "note":
		sprite.texture = load("res://assets/textures/entities/projectiles/" + texture + "_" + str(randi_range(0, 1)) + ".png")
	else:
		sprite.texture = load("res://assets/textures/entities/projectiles/" + texture + ".png")
	sprite.set_material(sprite.get_material().duplicate(true))
	sprite.material.set_shader_parameter("shift_hue", hue)
	direction = game.unit_circle(direction)
	if not friendly:
		damage = 1

func _physics_process(delta):
	global_position += direction * speed

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if (body.is_in_group("enemies") and friendly) or (body.is_in_group("player") and not friendly and body.dashCooldown <= body.DASHWAIT - body.DASHIMMUNITY):
		body.damage(damage)
		queue_free()
	elif body.is_in_group("walls"):
		queue_free()
