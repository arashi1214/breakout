extends Node

@export var HP = 3
@export var ball_birth_point : Marker2D

var ball_object
var HP_icon
var score = 0

func _ready() -> void:
	ball_object = preload("res://Objects/ball.tscn")
	HP_icon = preload("res://Assets/Q版齊絨正面.png")
	create_ball()

func create_ball():
	var ball = ball_object.instantiate()
	ball.position = ball_birth_point.position
	ball.out_of_bounds.connect(out_of_bounds)
	ball.get_score.connect(update_score)
	add_child(ball)

func out_of_bounds():
	HP -= 1
	$"UI/HP".get_child(HP).queue_free()
	if HP > 0:
		create_ball()
	else:
		$UI/NewGame.visible = true
		
func update_score():
	score += 1
	$UI/Label.text = str(score)
	
func reset_game():
	$UI/NewGame.visible = false
	
	# 紀錄分數
	
	# 分數歸零
	score = 0
	$UI/Label.text = str(score)
	
	# 玩家歸位
	$Player.reset()
	HP = 3
	
	
	create_ball()
	# 重新生成磚塊
	$bricksController.reset()
