extends CharacterBody2D

@export var speed = 1
var screen_size
var start_position

func _ready() -> void:
	screen_size = get_viewport_rect().size
	start_position = position
	
func _physics_process(_delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	elif Input.is_action_pressed("move_left"):
		velocity.x -= 1
		
	position += velocity
	position = position.clamp(Vector2.ZERO, Vector2(559, 900))

func reset():
	position = start_position
