extends CharacterBody2D


@export var brick_audio : AudioStreamOggVorbis
@export var player_audio : AudioStreamOggVorbis
@export var block_audio : AudioStreamOggVorbis

var status = false
var ball_status = false #初始狀態
var previous_velocity = Vector2.ZERO
var speed

const MIN_VERTICAL_SPEED_RATIO = 0.3

signal out_of_bounds()
signal get_score()

func _physics_process(_delta: float) -> void:
	if status:	
		# 避免水平移動
		enforce_minimum_vertical_velocity()
		
		# 移動並確認碰撞
		previous_velocity = velocity
		move_and_slide()
		
		# 碰撞後處理
		var collisions = get_slide_collision_count()
		if collisions > 0:
			
			for i in collisions:
				var collision = get_slide_collision(i)
				var collider_object = collision.get_collider()
				var normal = collision.get_normal()
					
				if "bricks" in collider_object.get_groups():
					if abs(normal.y) > 0.9: # 上下碰撞 (磚塊頂部/底部)
						velocity.y = previous_velocity.y * -1
					elif abs(normal.x) > 0.9: # 左右碰撞 (磚塊側面)
						velocity.x = previous_velocity.x * -1
					
					if velocity.y == 0:
						print("水平")
						velocity.y += 0.5
					if collider_object.kind_name == "Block":
						$AudioStreamPlayer.stream = block_audio
					else:
						$AudioStreamPlayer.stream = brick_audio
						emit_signal("get_score")
						collider_object.on_collision()
					
					if speed < 600:
						speed += 20
						
					$AudioStreamPlayer.play()
					
					if velocity.length() != 0.0:
						velocity = velocity.normalized() * speed
						enforce_minimum_vertical_velocity()
					return
					
				elif "player" in collider_object.get_groups():
					var normalized_offset = offset_distance(position, collider_object)
					apply_offset_to_velocity(normalized_offset)
					$AudioStreamPlayer.stream = player_audio
				
				elif "rebound" in collider_object.get_groups():
					if abs(normal.x) > 0.9: # 如果法線接近純水平 (左右牆)
						velocity.x = previous_velocity.x * -1
					elif abs(normal.y) > 0.9: # 如果法線接近純垂直 (上下牆)
						velocity.y = previous_velocity.y * -1
				else:
					# 確認是否出界
					print("出界")
					emit_signal("out_of_bounds")
					queue_free() 
					return
			
				$AudioStreamPlayer.play()

		if velocity.length() != 0.0:
			velocity = velocity.normalized() * speed
			enforce_minimum_vertical_velocity()

func play():
	if !ball_status:
		status = true
		ball_status = true
		velocity = Vector2(0, 1).normalized() * speed
			
# 強制確保最小垂直速度，防止純水平移動
func enforce_minimum_vertical_velocity() -> void:
	var current_speed = velocity.length()
	if current_speed == 0:
		return
	
	var min_y_speed = current_speed * MIN_VERTICAL_SPEED_RATIO
	
	# 如果垂直速度太小，重新調整速度向量
	if abs(velocity.y) < min_y_speed:
		# 保持原來的水平方向
		var x_sign = sign(velocity.x) if velocity.x != 0 else 1
		# 保持或恢復垂直方向（優先向上）
		var y_sign = sign(velocity.y) if velocity.y != 0 else -1
		
		# 計算新的速度分量
		var new_y = min_y_speed * y_sign
		var new_x = sqrt(current_speed * current_speed - new_y * new_y) * x_sign
		
		velocity = Vector2(new_x, new_y)


# 計算偏移量
func offset_distance(collision_point, collider_object):
	var collider_point = collider_object.position
	
	# 取得碰撞體的寬度資訊
	var collider_shape = collider_object.get_node("CollisionShape2D")
	var platform_shape: RectangleShape2D = collider_shape.shape
	var local_width = platform_shape.size.x  * collider_object.scale.x

	var offset_x = collision_point.x - (collider_point.x + local_width/2)
	var normalized_offset = offset_x / local_width

	return clamp(normalized_offset, -1.0, 1.0)
	
	
# 最大角度改變，控制偏轉強度，例如 75 度
const MAX_ANGLE_DEVIATION = deg_to_rad(75.0) 
# 最小向上速度佔總速度的比例，例如至少 30% 的速度用於向上
const MIN_Y_FACTOR = 0.3 

func apply_offset_to_velocity(normalized_offset: float) -> void:
	# 計算目標角度
	# Godot 角度: 0度(右), -90度(上), 90度(下)
	
	# 計算角度：從純垂直向上 (-90 度) 開始偏移
	var base_angle = deg_to_rad(-90.0) 
	
	# 偏移的角度：偏移量 * 最大偏轉角度
	var angle_change = normalized_offset * MAX_ANGLE_DEVIATION
	
	var new_angle = base_angle + angle_change
	
	# 限制角度範圍
	var min_angle = deg_to_rad(-150.0) 
	var max_angle = deg_to_rad(-30.0)
	new_angle = clamp(new_angle, min_angle, max_angle)
	
	var temp_velocity = Vector2.from_angle(new_angle) * speed
	
	if abs(temp_velocity.y) < speed * MIN_Y_FACTOR:
		var enforced_y_speed = speed * MIN_Y_FACTOR
	
		# X = sqrt(Speed^2 - Y^2)
		var enforced_x_speed = sqrt(speed * speed - enforced_y_speed * enforced_y_speed)
		
		velocity.x = enforced_x_speed * sign(temp_velocity.x)
		velocity.y = -enforced_y_speed
		
	else:
		velocity = temp_velocity
	#velocity = velocity.normalized() * speed
