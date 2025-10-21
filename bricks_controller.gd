extends Node

@export var hight = 12
@export var width = 5
@export var create_point : Marker2D
@export var props_list : Array

func _ready() -> void:
	create()

func create():
	var bricks = preload("res://Objects/bricks.tscn")
	var create_point_position = create_point.position
	
	for h in range(hight):
		for w in range(width):
			var brick = bricks.instantiate()
			brick.position = create_point_position
			
			if randi_range(0,100) % 2:
				brick.prop_name = props_list[randi_range(0, len(props_list)-1)]
				brick.has_prop.connect(drop_prop)
			
			add_child(brick)
			create_point_position.y += 25
		create_point_position.y = create_point.position.y
		create_point_position.x += 48	

func drop_prop(prop_name, prop_pos):
	var prop = load("res://Objects/props/" + prop_name + ".tscn")
	var new_prop = prop.instantiate()
	new_prop.position = prop_pos
	add_child(new_prop)

func reset():
	var all_children = get_children()
	for child in all_children:
		child.queue_free()
		
	create()
