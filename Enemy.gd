extends KinematicBody2D

export var corpse: PackedScene

var target = null
var aiming_direction = Vector2.RIGHT

var velocity = Vector2.ZERO

var hand_item = null

var target_offset = Vector2(0,0)

var looking_for_target = false

var inaccuracy = 20
var speed = 40

var movement_list = []

func _ready():
	if not hand_item:
		var rifle_instance = MetaData.pistol.instance()
		$Handpivot/Hand.add_child(rifle_instance)
		hand_item = rifle_instance
	$Timer2.wait_time = rand_range(0.8,1.2)

func _physics_process(delta):
	if not is_instance_valid(target):
		target = null
	
	if target:
		aiming_direction = ((target.global_position+target_offset) - self.global_position).normalized()
		$Handpivot.rotation_degrees = rad2deg(aiming_direction.angle())
	if abs(rad2deg(aiming_direction.angle())) > 90:
		$Handpivot/Hand.scale.y = -1
	else:
		$Handpivot/Hand.scale.y = 1
	
	if movement_list:
		move()
	else:
		velocity.x = move_toward(velocity.x,0,5)
	
	if not is_on_floor():
		velocity.y += 1
	else:
		velocity.y = 0
	
	move_and_slide(velocity)

func generate_movement():
	var list_item = {"direction": Vector2(rand_range(-1,1),0).normalized(),"time": rand_range(100,1000),"current_time": Time.get_ticks_msec()}
	movement_list.append(list_item)


func move():
	var compared_time = movement_list[0]["current_time"] + movement_list[0]["time"]
	var time = Time.get_ticks_msec()
	
	if time > compared_time:
		movement_list.remove(0)
		return
	
	velocity.x += movement_list[0]["direction"].x * 5
	
	velocity.x = clamp(velocity.x,-speed,speed)




func update_target(seen_players):
	var players = seen_players
	var closest_player = get_closest(players)
	if closest_player:
		target = closest_player
	
	if target:
		inform_others(target)

func inform_others(target):
	var bodies = $Area2D.get_overlapping_bodies()
	var enemies = []
	for item in bodies:
		if item.is_in_group("enemy"):
			enemies.append(item)
	
	for item in enemies:
		if not item.target:
			item.target = target

func shoot():
	if hand_item:
		if hand_item.has_method("shoot"):
			hand_item.shoot()
			hand_item.release_trigger()
			hand_item.ammo += 1
			if hand_item.ammo:
				$AnimationPlayer.play("shoot")
	
	target_offset = Vector2(rand_range(-inaccuracy,inaccuracy),rand_range(-inaccuracy,inaccuracy))

func despawn():
	queue_free()

func get_hit():
	drop_weapon()
	var corpse_instance = corpse.instance()
	get_parent().add_child(corpse_instance)
	corpse_instance.global_position = self.global_position
	corpse_instance.angular_velocity = rand_range(-5,5)
	despawn()

func explode(explosion_position,explosion_strength):
	drop_weapon()
	
	var direction = (self.global_position - explosion_position).normalized()
	
	var corpse_instance = corpse.instance()
	get_parent().add_child(corpse_instance)
	corpse_instance.apply_central_impulse(direction * explosion_strength)
	corpse_instance.global_position = self.global_position
	if explosion_position.x - global_position.x > 0:
		corpse_instance.angular_velocity = -5
	else:
		corpse_instance.angular_velocity = 5
	despawn()


func drop_weapon():
	if hand_item:
		var dropped_item = hand_item.droppable.instance()
		get_parent().add_child(dropped_item)
		dropped_item.ammo = hand_item.ammo
		dropped_item.global_position = hand_item.global_position
		dropped_item.global_rotation = hand_item.global_rotation
		dropped_item.scale.x = $Handpivot/Hand.scale.y
		hand_item.queue_free()
		hand_item = null

func get_closest(list):
	if not list:
		return
	var nearest = list[0]
	for item in list:
		if (item.global_position - self.global_position).length() < (nearest.global_position - self.global_position).length():
			nearest = item
	return nearest


func check_for_target(enemy_position, player_position, player_size):
	var space_state = get_world_2d().direct_space_state
	var ray_results = []

	# Define critical points on the player
	var head_position = player_position + Vector2(0, -player_size / 2)  # Adjust for head height
	var torso_position = player_position  # Center of the player
	var feet_position = player_position + Vector2(0, player_size / 2)  # Adjust for feet

	# Points to raycast
	var points = [head_position, torso_position, feet_position]
	var exclude = [self]
	# Perform raycasts for each point
	for point in points:
		var collision = space_state.intersect_ray(enemy_position, point, exclude, 0b11)  # Adjust mask
		if collision:
			# Check if ray hits the player
			if collision.collider.is_in_group("player"):  # Adjust based on your player node
				ray_results.append(collision.collider)
			else:
				pass
		else:
			pass
	
	# If any ray hits the player, they are visible
	return ray_results






func _on_Timer2_timeout():
	var friendly_fire = false
	if is_instance_valid(target):
		pass
	else:
		return
	
	if target:
		friendly_fire = check_friendly_fire($Handpivot/Hand.global_position,target.global_position,1000)
	if target and not friendly_fire:
		shoot()


func check_friendly_fire(shooter_position, target_position, shooting_range):
	var space_state = get_world_2d().direct_space_state

	# Cast a ray from the shooter to the target position
	var end_position = target_position  # Target position (could be player or enemy)
	
	# Exclude self (the shooter) from the raycast
	var exclude = [self]

	# Correct layer mask for enemies on layer 1 (0b01 or 1)
	var collision_mask = 0b01  # Layer 1 for enemies

	# Perform the raycast
	var collision = space_state.intersect_ray(shooter_position, end_position, exclude, collision_mask)

	if collision:
		# Check if the ray hit a node in the "enemy" group
		if collision.collider.is_in_group("enemy"):
			print("Enemy detected: ", collision.collider.name)
			return true  # Enemy hit
		else:
			print("Ray hit something else: ", collision.collider.name)
			return false  # Hit something else
	else:
		print("No collision detected on the shooting line.")
		return false  # No hit


func _on_movement_timer_timeout():
	if target:
		generate_movement()


func _on_RaycastTimer_timeout():
	var players = get_tree().get_nodes_in_group("player")
	var seen_players
	
	for item in players:
		var target_list = check_for_target($Position2D.global_position,item.global_position,37)
		if target_list:
			seen_players = target_list
	
	if seen_players:
		update_target(seen_players)
	else:
#		target = null
		pass
	


func _on_EnemyLostTimer_timeout():
	target = null
