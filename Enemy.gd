extends KinematicBody2D

export var corpse: PackedScene

var target = null
var aiming_direction = Vector2.RIGHT

var velocity = Vector2.ZERO

var hand_item = null

var target_offset = Vector2(0,0)

var inaccuracy = 40
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




func update_target():
	var players = get_tree().get_nodes_in_group("player")
	var closest_player = get_closest(players)
	if closest_player:
		target = closest_player


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


func _on_Timer_timeout():
	update_target()


func _on_Timer2_timeout():
	if target:
		shoot()


func _on_movement_timer_timeout():
	generate_movement()
