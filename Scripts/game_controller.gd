extends Node

@export var HP = 100
@export var MaxHP = 100
@export var bar_width = 200
@export var bar_height := 20

@export var ball_birth_point : Marker2D
@export var ball_speed = 100

var ball_object
var score = 0
var game_status = true


func _ready() -> void:
	ball_object = preload("res://Objects/ball.tscn")
	$Player.HP_update.connect(use_HP_prop)
	$bricksController.GameClear.connect(game_finish)
	create_ball()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		$"數值調整".visible = !$"數值調整".visible
		pause()

func pause():
	$Player.status = !game_status
	var balls = get_tree().get_nodes_in_group("ball")
	
	for ball in balls:
		ball.status = !game_status
	
	game_status = !game_status

func create_ball():
	var ball = ball_object.instantiate()
	ball.position = ball_birth_point.position
	ball.out_of_bounds.connect(out_of_bounds)
	ball.get_score.connect(update_score)
	ball.speed = ball_speed
	add_child(ball)

func use_HP_prop():
	set_hp(HP + 10)
		
func set_hp(value):
	HP = clamp(value, 0, MaxHP)
	update_HP_bar()
	
func update_HP_bar():
	# 計算血條比例
	var bar = $UI/HP/HP_bar
	var ratio = HP / float(MaxHP)
	var current_width = bar_width * ratio

	# 更新血條長度
	bar.polygon = PackedVector2Array([
		Vector2(90, 37),
		Vector2(90 + current_width, 37),
		Vector2(90 + current_width, 37 + bar_height),
		Vector2(90, 37 + bar_height)
	])
	
	$UI/HP/HP_number.text = str(HP)
	
func use_buff_to_player(buff):
	match buff:
		"Medicine":
			use_HP_prop()
		"Poison":
			deduct_HP()
		"Blood return":
			pass

func deduct_HP():
	set_hp(HP - 10)
	if HP <= 0:
		game_finish()

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
	
	# 暫停一切移動
	pause()

func reset_game():
	$UI/NewGame.visible = false
	
	# 紀錄分數
	
	# 分數歸零
	score = 0
	$UI/Label.text = str(score)
	
	# 玩家歸位
	$Player.reset()
	set_hp(100)
	
	# 清空並重新生成球
	var balls = get_tree().get_nodes_in_group("ball")
	
	for ball in balls:
		ball.queue_free()
	
	create_ball()
	
	# 重新生成磚塊
	$bricksController.reset()
