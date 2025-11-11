extends CharacterBody2D

@export var speed = 1

var screen_size
var start_position
var start_scale

signal HP_update()

func _ready() -> void:
	screen_size = get_viewport_rect().size
	start_position = position
	start_scale = scale
	
	
func _physics_process(_delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	elif Input.is_action_pressed("move_left"):
		velocity.x -= speed
		
	position += velocity
	position = position.clamp(Vector2.ZERO, Vector2(screen_size.x - $CollisionShape2D.shape.size.x * scale.x, screen_size.y))

func useprop(prop_name):
	match prop_name:
		"Prop_long":
			if scale.x <= 2:
				scale.x += 0.2
		"Prop_short":
			if scale.x >= 0.2:
				scale.x -= 0.2
		"Prop_HP":
			emit_signal("HP_update")
		_:
			pass

func reset():
	position = start_position
	scale = start_scale
