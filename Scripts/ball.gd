extends CharacterBody2D

@export var speed = 100
@export var brick_audio : AudioStreamOggVorbis
@export var player_audio : AudioStreamOggVorbis

var status = false
var previous_velocity = Vector2.ZERO

signal out_of_bounds()
signal get_score()

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("Space") and !status:
		status = true
		velocity = Vector2(0, 1).normalized() * speed
	if status:
		if velocity.length() != 0.0:
			velocity = velocity.normalized() * speed
		
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
					
					print("test")
					emit_signal("get_score")
					collider_object.on_collision()
					
					if speed < 250:
						speed += 10
					$AudioStreamPlayer.stream = brick_audio
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
	# 1. 計算理想的目標角度
	# 偏移量為 -1.0 應產生向左上 (例如 180 - 75 = 105 度)
	# 偏移量為  1.0 應產生向右上 (例如 0 + 75 = 75 度)
	# 由於 Godot 角度: 0度(右), -90度(上), 90度(下)
	
	# 計算角度：從純垂直向上 (-90 度) 開始偏移
	var base_angle = deg_to_rad(-90.0) 
	
	# 偏移的角度：偏移量 * 最大偏轉角度
	var angle_change = normalized_offset * MAX_ANGLE_DEVIATION
	
	var new_angle = base_angle + angle_change
	
	# 2. 限制角度範圍 (確保球不會向下射)
	# 向上飛行的合理範圍：-150度 到 -30度
	var min_angle = deg_to_rad(-150.0) 
	var max_angle = deg_to_rad(-30.0)
	new_angle = clamp(new_angle, min_angle, max_angle)
	
	# 3. 確保 Y 軸分量足夠大
	# 計算基於新角度的暫定速度向量
	var temp_velocity = Vector2.from_angle(new_angle) * speed
	
	# 如果 Y 軸速度（向上的絕對值）太小，強制修正 Y 軸速度
	# velocity.y 是負值 (向上)，所以我們用 abs()
	if abs(temp_velocity.y) < speed * MIN_Y_FACTOR:
		# 保持 X 軸方向，但強制 Y 軸速度為 MIN_Y_FACTOR * speed
		var enforced_y_speed = speed * MIN_Y_FACTOR
		
		# 重新計算 X 軸速度，保持總速度大小不變
		# X = sqrt(Speed^2 - Y^2)
		var enforced_x_speed = sqrt(speed * speed - enforced_y_speed * enforced_y_speed)
		
		# 應用修正：保持 X 軸的原方向
		velocity.x = enforced_x_speed * sign(temp_velocity.x)
		# 應用修正：保持 Y 軸為負值 (向上)
		velocity.y = -enforced_y_speed
		
	else:
		# 如果 Y 軸速度足夠大，直接使用新角度
		velocity = temp_velocity
		
	# 4. 最終鎖定速度大小 (這是一個安全檢查，但應該已經處理了)
	velocity = velocity.normalized() * speed


'''
1. 球從下往上打的時候，不會往下反彈，會繼續向上的問題
2. 加速度後，碰到底下出界區域，會直接多次判斷，導致整個死亡
'''
