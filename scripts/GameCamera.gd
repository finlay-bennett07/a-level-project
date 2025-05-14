extends Camera2D

var fullHeart : Texture2D = load("res://assets/textures/ui/overlay/heart_2.png")
var halfHeart : Texture2D = load("res://assets/textures/ui/overlay/heart_1.png")
var emptyHeart : Texture2D = load("res://assets/textures/ui/overlay/heart_0.png")
var miss : Texture2D = load("res://assets/textures/ui/ranks/miss.png")
var ok : Texture2D = load("res://assets/textures/ui/ranks/ok.png")
var good : Texture2D = load("res://assets/textures/ui/ranks/good.png")
var great : Texture2D = load("res://assets/textures/ui/ranks/great.png")
var excellent : Texture2D = load("res://assets/textures/ui/ranks/excellent.png")
@onready var game = $/root/Game
@onready var player = $/root/Game/Player
@onready var rank = get_node("Rank")

func _process(delta):
	rank.get_node("Label").visible = player.get_node("Character/Weapon").combo >= 16
	get_node("EnemyCount/Current").text = str(game.score)
	get_node("EnemyCount/Goal").text = str(game.goal)
	get_node("Floor").text = "Floor " + str(game.floor)
	
	rank.scale = lerp(rank.scale, Vector2(8, 8), 0.3)
	get_node("EnemyCount/Current").scale = lerp(get_node("EnemyCount/Current").scale, Vector2(1, 1), 0.2)
	get_node("Floor").scale = lerp(get_node("Floor").scale, Vector2(1, 1), 0.05)
	
	if player.health >= 2:
		get_node("Heart0").texture = fullHeart
	elif player.health >= 1:
		get_node("Heart0").texture = halfHeart
	else:
		get_node("Heart0").texture = emptyHeart
	
	if player.health >= 4:
		get_node("Heart1").texture = fullHeart
	elif player.health >= 3:
		get_node("Heart1").texture = halfHeart
	else:
		get_node("Heart1").texture = emptyHeart
	
	if player.health >= 6:
		get_node("Heart2").texture = fullHeart
	elif player.health >= 5:
		get_node("Heart2").texture = halfHeart
	else:
		get_node("Heart2").texture = emptyHeart

func score(accuracy : int):
	rank.scale = Vector2(12, 12)
	match accuracy:
		game.rank.EXCELLENT:
			rank.texture = excellent
		game.rank.GREAT:
			rank.texture = great
		game.rank.GOOD:
			rank.texture = good
		game.rank.OK:
			rank.texture = ok
		_:
			rank.texture = miss

func kill():
	get_node("EnemyCount/Current").scale = Vector2(1.8, 1.8)

func floor():
	get_node("Floor").scale = Vector2(3, 3)
