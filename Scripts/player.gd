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
	position = position.clamp(Vector2.ZERO, Vector2(screen_size.x - $CollisionShape2D.shape.size.x * scale.x, screen_size.y))

func useprop(prop_name):
	match prop_name:
		"Prop_long":
			scale.x += 0.2
		"Prop_short":
			if scale.x >= 0.3:
				scale.x -= 0.2

func reset():
	position = start_position
