extends Node

@export var HP = 3
@export var MaxHP = 5
@export var ball_birth_point : Marker2D

var ball_object
var HP_icon
var score = 0
var ball_speed = 100

func _ready() -> void:
	ball_object = preload("res://Objects/ball.tscn")
	HP_icon = preload("res://Objects/HP_icon.tscn")
	$Player.HP_update.connect(use_HP_prop)
	$bricksController.GameClear.connect(game_finish)
	create_ball()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		$"數值調整".visible = !$"數值調整".visible


func create_ball():
	var ball = ball_object.instantiate()
	ball.position = ball_birth_point.position
	ball.out_of_bounds.connect(out_of_bounds)
	ball.get_score.connect(update_score)
	ball.speed = ball_speed
	add_child(ball)

func use_HP_prop():
	if HP < 5:
		HP += 1
		var newHP = HP_icon.instantiate()
		newHP.name = str(HP)
		newHP.position.x = 40 * HP
		newHP.position.y = 30
		$"UI/HP".add_child(newHP)

func use_buff_to_player(buff):
	match buff:
		"Medicine":
			use_HP_prop()
		"Poison":
			deduct_HP()
		"Blood return":
			pass

func deduct_HP():
	HP -= 1
	$"UI/HP".get_child(HP).queue_free()
	if HP <= 0:
		$UI/NewGame.visible = true

func out_of_bounds():
	deduct_HP()
	if HP > 0:
		create_ball()
		
func update_score():
	score += 1
	$UI/Label.text = str(score)
	
func game_finish():
	# 顯示分數
	
	$UI/NewGame.visible = true	

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
