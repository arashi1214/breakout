extends Node

@export var hight = 12
@export var width = 5
@export var create_point : Marker2D
@export var GameController : Node
@export var brickstable : RandomTable

var total = 0
signal GameClear()

func _ready() -> void:
	create()

func create():
	var bricks = preload("res://Objects/bricks.tscn")
	var create_point_position = create_point.position
	
	for h in range(hight):
		for w in range(width):
			var brick = bricks.instantiate()
			brick.position = create_point_position
			brick.disappear.connect(check_remain_bricks)
			
			# 隨機生成磚塊種類
			brick.kind_name = brickstable.get_random()
			brick.has_prop.connect(drop_prop)
			brick.triger_buff.connect(GameController.use_buff_to_player)
				
			add_child(brick)
			total += 1
			create_point_position.y += 25
		create_point_position.y = create_point.position.y
		create_point_position.x += 48	

func drop_prop(prop_name, prop_pos):
	var prop = load("res://Objects/props/" + prop_name + ".tscn")
	var new_prop = prop.instantiate()
	new_prop.position = prop_pos
	add_child(new_prop)


func check_remain_bricks():
	total -= 1
	if total == 0:
		emit_signal("GameClear")
		print("Game finish")

func reset():
	var all_children = get_children()
	for child in all_children:
		child.queue_free()
		
	create()
