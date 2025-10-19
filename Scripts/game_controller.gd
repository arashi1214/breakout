extends Node

@export var HP = 3
@export var ball_birth_point : Marker2D

var ball_object
var score

func _ready() -> void:
	ball_object = preload("res://Objects/ball.tscn")
	create_ball()

func create_ball():
	var ball = ball_object.instantiate()
	ball.position = ball_birth_point.position
	ball.out_of_bounds.connect(out_of_bounds)
	add_child(ball)

func out_of_bounds():
	HP -= 1
	if HP > 0:
		create_ball()
	else:
		print("Game Over")
