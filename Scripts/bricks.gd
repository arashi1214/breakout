extends StaticBody2D

@export var HP = 1
signal has_prop(prop_name, create_position)

var prop_name = ""

func on_collision():
	HP -= 1
	if HP <= 0:
		if prop_name:
			emit_signal("has_prop", prop_name, position)
		queue_free()
