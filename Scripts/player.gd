extends CharacterBody2D

@export var speed = 1

var screen_size
var start_position
var start_scale
var status = false
var reversal_status = false
var finger_move_to = "release"

func _ready() -> void:
	screen_size = get_viewport_rect().size
	start_position = position
	start_scale = scale
	
	
func _physics_process(_delta):
	# 開始後平台才可以移動
	if Input.is_action_pressed("Interactive") and !status:
		status = true
	
	if status:
		var velocity = Vector2.ZERO
		var body = $player_body
		if !reversal_status:
			
			if Input.is_action_pressed("move_right") or finger_move_to == "right":
				velocity.x += speed
				body.flip_h = false
			elif Input.is_action_pressed("move_left") or finger_move_to == "left":
				velocity.x -= speed
				body.flip_h = true
		else:
			if Input.is_action_pressed("move_right") or finger_move_to == "right":
				velocity.x -= speed
				body.flip_h = true
			elif Input.is_action_pressed("move_left") or finger_move_to == "left":
				velocity.x += speed
				body.flip_h = false
			
		position += velocity
		position = position.clamp(Vector2.ZERO, Vector2(screen_size.x - $CollisionShape2D.shape.size.x * scale.x, screen_size.y))

func _input(event: InputEvent) -> void:
	var player_w = $CollisionShape2D.shape.size.x/2
	
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x > position.x + player_w:
				finger_move_to = "right"
			elif event.position.x < position.x + player_w:
				finger_move_to = "left"
			else:
				finger_move_to = "release"
		
		else:
			finger_move_to = "release"
			
	if event is InputEventScreenDrag:	
		if event.position.x > position.x + player_w:
			finger_move_to = "right"
		elif event.position.x < position.x + player_w:
			finger_move_to = "left"
		else:
			finger_move_to = "release"
				
func useprop(prop_name):
	var bamboo_image = $TextureRect
	var bamboo_collision = $CollisionShape2D
	
	match prop_name:
		"Prop_long":
			if bamboo_collision.scale.x <= 2:
				bamboo_image.scale.x += 0.2
				bamboo_collision.scale.x += 0.2
		"Prop_short":
			if bamboo_collision.scale.x >= 0.2:
				bamboo_image.scale.x -= 0.2
				bamboo_collision.scale.x -= 0.2
		"Prop_operation_reversal":
			change_face("reversal", 5)
			reversal_status = true
			$Timer.start()
			
		_:
			pass

func change_face(which_face:String, time:int):
	var face = $player_face
	var face_Timer = $face_timer
	
	if !reversal_status or time == -1:
		face.animation = which_face
	
	if time != -1:
		face_Timer.wait_time = time
		face_Timer.start()

func _on_timer_timeout() -> void:
	reversal_status = false
	
func face_back_to_default():
	change_face("default", -1)

func reset():
	position = start_position
	$TextureRect.scale.x = start_scale.x
	$CollisionShape2D.scale.x = start_scale.x
	status = false
	reversal_status = false
