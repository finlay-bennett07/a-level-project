extends Node2D

enum enemies {REDSLIME, BLUESLIME}
enum rank {EXCELLENT, GREAT, GOOD, OK, MISS}

var tileset : int
var bgColor : Color
var bpm : int = 145
var tpb : float = 60.0 / bpm
var nearestBeat : float
var timeElapsed : float = 0.1
var beatsElapsed : int = 0

var map : int
var spawned : int = 0
var totalScore : int
var score : int
var goal : int
var floor : int = 0
var bestCombo : int
var excellents : int
var totalTimeElapsed : float

var enemyScene : PackedScene = preload("res://scenes/enemy.tscn")
@onready var player : CharacterBody2D = get_node("Player")
@onready var tileSet : TileSet = get_node("NavigationRegion2D/TileMap").tile_set
@onready var audioPlayer : AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var camera : Camera2D = get_node("GameCamera")

func _ready():
	audioPlayer.stream = load("res://assets/audio/music/gameplay_0.mp3")
	audioPlayer.play()
	new_floor()

func _process(delta):
	if player.get_node("Character/Weapon").combo > bestCombo:
		bestCombo = player.get_node("Character/Weapon").combo
	
	if score >= goal and get_node("NewFloorTimer").time_left <= 0:
		get_node("NewFloorTimer").start()
	
	timeElapsed += delta
	totalTimeElapsed += delta
	
	var prevBeats = beatsElapsed
	beatsElapsed = floor(timeElapsed / tpb)
	if timeElapsed - (beatsElapsed * tpb) <= 0.5 * tpb:
		nearestBeat = timeElapsed - (beatsElapsed * tpb)
	else:
		nearestBeat = tpb - (timeElapsed - (beatsElapsed * tpb))
	
	if beatsElapsed > prevBeats:
		for c in get_children():
			if c.is_in_group("enemies"):
				c.beat()

func _on_timer_timeout():
	if spawned < goal:
		spawn_enemy(randi_range(0, len(enemies) - 1))
		spawned += 1

func _on_new_floor_timer_timeout():
	new_floor()

func _on_audio_stream_player_finished():
	audioPlayer.play()
	timeElapsed = 0.1
	beatsElapsed = 0

func new_floor():
	camera.floor()
	map = randi_range(0, 3)
	player.global_position = get_node("Maps/Map" + str(map)).global_position
	
	floor += 1
	goal = floor((floor * 3) ** 1.1)
	totalScore += score
	score = 0
	spawned = 0
	
	tileset = randi_range(0, 1)
	match tileset:
		1:
			bgColor = Color("666666")
		_:
			bgColor = Color("023F00")
	RenderingServer.set_default_clear_color(bgColor)
	tileSet.get_source(0).texture = load("res://assets/textures/tiles/tileset_" + str(tileset) + ".png")

func spawn_enemy(type : int) -> void:
	var enemy = enemyScene.instantiate()
	match type:
		enemies.REDSLIME:
			enemy.health = 4.5
			enemy.speed = 240
			enemy.color = Color(95, 0, 0, 255)
			enemy.identifier = "red_slime"
		enemies.BLUESLIME:
			enemy.health = 2
			enemy.speed = 120
			enemy.color = Color(0, 0, 95, 255)
			enemy.identifier = "blue_slime"
	enemy.global_position = get_node("Maps/Map" + str(map) + "/Spawn" + str(randi_range(0, 2))).global_position
	enemy.type = type
	add_child(enemy)

func unit_circle(vector : Vector2) -> Vector2:
	vector = vector.normalized()
	return vector * (1.0 / (((vector[0] ** 2) + (vector[1] ** 2)) ** (1/2)))
