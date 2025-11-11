extends StaticBody2D

@export var HP = 1
signal has_prop(prop_name, create_position)
signal disappear()

var prop_name = ""

func on_collision():
	HP -= 1
	if HP <= 0:
		emit_signal("disappear")
		if prop_name:
			emit_signal("has_prop", prop_name, position)
		call_deferred("queue_free")
