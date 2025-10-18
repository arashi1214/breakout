extends Node

@export var hight = 12
@export var width = 5
@export var create_point : Marker2D

func _ready() -> void:
	var bricks = preload("res://Objects/bricks.tscn")
	var create_point_position = create_point.position
	
	for h in range(hight):
		for w in range(width):
			var brick = bricks.instantiate()
			brick.position = create_point_position
			
			add_child(brick)
			create_point_position.y += 25
		create_point_position.y = create_point.position.y
		create_point_position.x += 48
