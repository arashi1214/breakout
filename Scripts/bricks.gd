extends StaticBody2D

@export var HP = 1
@export var propstable : RandomTable
@export var bricksImage : Array[Texture2D] = []

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
		"Normal", "Block":
			pass
		_:
			buff_name = kind_name
			
	update_image()

func on_collision():
	HP -= 1
	if HP <= 0:
		if kind_name == "Normal":
			emit_signal("disappear")
		if prop_name:
			emit_signal("has_prop", prop_name, position)
		if buff_name:
			emit_signal("triger_buff", buff_name)
		call_deferred("queue_free")

func update_image():
	var image = $Sprite2D
	match kind_name:
		"Medicine":
			image.texture = bricksImage[1]
		"Poison":
			image.texture = bricksImage[2]
		"Block":
			image.texture = bricksImage[3]
