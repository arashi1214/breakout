extends Area2D
class_name Props

func _ready() -> void:
	body_entered.connect(touch)
	
func touch(body):
	match body.name:
		"Player":
			#讓玩家使用道具
			body.useprop(name)
			queue_free()
		"界外":
			queue_free()

func _process(_delta: float) -> void:
	position.y += 1
