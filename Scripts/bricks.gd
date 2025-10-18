extends StaticBody2D

@export var HP = 1

func on_collision():
	HP -= 1
	if HP <= 0:
		queue_free()
