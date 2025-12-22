extends Node

@export var HP = 100
@export var MaxHP = 100
@export var bar_width = 200
@export var bar_height := 20

@export var ball_birth_point : Marker2D
@export var ball_speed = 100

var ball_object
var score = 0
var maxscore = 0
var game_status = true
var level = 1
var maxlevel = 5
var ball_instantiate
var status = false

func _ready() -> void:
	ball_object = preload("res://Objects/ball.tscn")
	$bricksController.GameClear.connect(game_finish)
	create_ball()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		#$"數值調整".visible = !$"數值調整".visible
		pause()
		
	if Input.is_action_pressed("Interactive"):
		game_start()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			game_start()


func game_start():
	if !status:
		$UI/Tips.visible = false
		$Player.status = true
		status = true
	if ball_instantiate:
		ball_instantiate.play()
		
func pause():
	$Player.status = !game_status
	var ball = get_tree().get_first_node_in_group("ball")
	
	ball.status = !game_status
	game_status = !game_status

func create_ball():
	var ball = ball_object.instantiate()
	ball.position = ball_birth_point.position
	ball.out_of_bounds.connect(out_of_bounds)
	ball.get_score.connect(update_score)
	ball.speed = ball_speed
	
	add_child(ball)
	ball_instantiate = ball

func use_HP_prop():
	set_hp(HP + 10)
		
func set_hp(value):
	HP = clamp(value, 0, MaxHP)
	
	var HP_bar = $UI/HP
	var ratio = HP / float(MaxHP)
	var current_width = 3 + ratio * 90
	HP_bar.value = current_width

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
		game_finish("GameOver")
		$Player.change_face("game over", 20)
		

func out_of_bounds():
	deduct_HP()
	if HP > 0:
		create_ball()
		$Player.position = $Player.start_position
		$Player.change_face("Injured", 1)
		
		
func update_score():
	score += 1
	$UI/Score.text = str(score)
	
func game_finish(level_status : String):
	# 顯示分數
	
	# 根據狀態顯示重置還是下一關的按鈕
	if level_status == "GameClear" and level < maxlevel:
		$UI/Next.visible = true	
		level += 1
		ball_instantiate.queue_free()
	# 暫停一切移動
	else:
		$UI/NewGame.visible = true	
		
		# 更新最高分
		if score > maxscore:
			maxscore = score
		
		$UI/Highscore.text = "最高分數：" + str(maxscore)
		$UI/Highscore.visible = true
		
		# 重製關卡
		level = 1
	print("level", level)
	pause()

func reset_game():
	$UI/NewGame.visible = false
	$UI/Next.visible = false
	$UI/Highscore.visible = false
	
	# 將分數歸零
	if level == 1:
		score = 0
		$UI/Score.text = str(score)
	
	$bricksController.brickstable = load("res://data/bricks_kind_level" + str(int(level)) + ".tres")
	
	# 玩家歸位
	$Player.reset()
	$Player.change_face("default", -1)
	set_hp(100)

	create_ball()
	
	# 重新生成磚塊
	$bricksController.reset()
	
	status = false
