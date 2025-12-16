extends Node

@export var hight = 12
@export var width = 5
@export var create_point : Marker2D
@export var GameController : Node
@export var brickstable : RandomTable

var game_status = false

signal GameClear(level_status)

func _ready() -> void:
	create()

func _process(_delta: float) -> void:
	if game_status:
		check_remain_bricks()

func create():
	var bricks = preload("res://Objects/bricks.tscn")
	var create_point_position = create_point.position
	
	for h in range(hight):
		for w in range(width):
			var brick = bricks.instantiate()
			brick.position = create_point_position
			
			# 隨機生成磚塊種類
			brick.kind_name = brickstable.get_random()
			brick.has_prop.connect(drop_prop)
			brick.triger_buff.connect(GameController.use_buff_to_player)
			
			# 僅計算一般方塊，打完即可通關
			if brick.kind_name == "Normal" or  brick.kind_name == "Prop":
				brick.add_to_group("Normal_bricks")
			
			add_child(brick)
			
			create_point_position.y += 25
		create_point_position.y = create_point.position.y
		create_point_position.x += 48	
		
	game_status = true
	

func drop_prop(prop_name, prop_pos):
	var prop = load("res://Objects/props/" + prop_name + ".tscn")
	var new_prop = prop.instantiate()
	new_prop.position = prop_pos
	add_child(new_prop)


func check_remain_bricks():
	# 確認剩餘的磚塊數量
	var destroyed_count = get_tree().get_node_count_in_group("Normal_bricks")

	if destroyed_count <= 0:
		emit_signal("GameClear", "GameClear")
		game_status = false
		print("Game finish")

func reset():
	var all_children = get_children()
	for child in all_children:
		child.queue_free()
	
	create()
