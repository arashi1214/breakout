extends CharacterBody2D

var move_x = 1
var move_y = 1
@export var speed = 2


func _physics_process(_delta: float) -> void:
	var velocity = Vector2.ZERO
	
	velocity.x += move_x
	velocity.y += move_y
	
	position += velocity * speed
	
	# 移動並確認碰撞
	move_and_slide()
	
	# 碰撞後處理
	var collisions = get_slide_collision_count()
	if collisions > 0:
		for i in collisions:
			var collision = get_slide_collision(i)
			var collider_object = collision.get_collider()
			var normal = collision.get_normal()
	
			# 反射	
			move_x = velocity.bounce(normal).x
			move_y = velocity.bounce(normal).y
				
				
			# 確認是否出界
			if "rebound" not in collider_object.get_groups():
				print("出界")
				queue_free()

			#print(move_y)


# 暫時不使用計算偏移量
func offset_distance(collision_point, collider_object):
	var collider_point = collider_object.position
	
	print("碰撞點座標", collision_point)
	print("碰撞物座標", collider_object.position)
	
	# 取得碰撞體的寬度資訊
	var collider_shape = collider_object.get_node("CollisionShape2D")
	var platform_shape: RectangleShape2D = collider_shape.shape
	var local_width = platform_shape.size.x
	
	var offset_x = collision_point.x - collider_point.x
	var normalized_offset = offset_x / local_width
	
	return clamp(normalized_offset, -1.0, 1.0)
	
	
	
	
