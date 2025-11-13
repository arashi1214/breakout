extends StaticBody2D

@export var HP = 1
@export var propstable : RandomTable

signal has_prop(prop_name, create_position)
signal triger_buff(buff_name)
signal disappear()

var kind_name
var prop_name
var buff_name

func _ready() -> void:
	match kind_name:
		"Prop":
			prop_name = propstable.get_random()
		"Normal":
			pass
		_:
			buff_name = kind_name
			update_color()

func on_collision():
	HP -= 1
	if HP <= 0:
		emit_signal("disappear")
		if prop_name:
			emit_signal("has_prop", prop_name, position)
		if buff_name:
			emit_signal("triger_buff", buff_name)
		call_deferred("queue_free")

func update_color():
	match buff_name:
		"Medicine":
			$Polygon2D.color = "Green"
		"Poison":
			$Polygon2D.color = "Red"
		"Blood return":
			$Polygon2D.color = "Purple"
