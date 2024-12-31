extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 60
var jump_strength = 45

var hand_item

export var corpse: PackedScene
export var grenade: PackedScene

export var player_id: int



var grenades = 2
var grenade_power = 100

var on_ladder = false

func _ready():
	if not hand_item:
		var pistol_instance = MetaData.pistol.instance()
		$Handpivot/Hand.add_child(pistol_instance)
		hand_item = pistol_instance
	else:
		var weapon_instance = hand_item.instance()
		$Handpivot/Hand.add_child(weapon_instance)


func handle_input():
	
	var right_stick_x = Input.get_joy_axis(player_id,JOY_AXIS_2)
	var right_stick_y = Input.get_joy_axis(player_id,JOY_AXIS_3)
	
	var right_stick_direction = Vector2(right_stick_x, right_stick_y)
	
	right_stick_direction = (get_global_mouse_position() - self.global_position).normalized()
	
	if right_stick_direction.length() > 0.1:
		$Handpivot.rotation_degrees = rad2deg(right_stick_direction.angle())
	
	if abs(rad2deg(right_stick_direction.angle())) > 90:
		$Handpivot/Hand.scale.y = -1
	else:
		$Handpivot/Hand.scale.y = 1
	
	var areas = $Area2D.get_overlapping_areas()
	
	on_ladder = false
	
	for item in areas:
		if item.is_in_group("ladder"):
			on_ladder = true
			break
	
	if Input.is_action_pressed("p1_shoot"):
		if hand_item:
			if hand_item.has_method("shoot"):
				hand_item.shoot()
				if hand_item.ammo:
					$AnimationPlayer.play("shoot")
	if Input.is_action_just_released("p1_shoot"):
		if hand_item:
			if hand_item.has_method("release_trigger"):
				hand_item.release_trigger()
	
#		if Input.is_action_just_pressed("p%s_shoot" , player_id):
#		if hand_item.has_method("shoot"):
#			hand_item.shoot()
	
	if Input.is_action_just_pressed("p1_dropweapon" , player_id):
		if hand_item:
			drop_weapon()
		else:
			pickup_weapon()
	
	if Input.is_action_just_released("p1_throwgrenade"):
		if grenades > 0:
			var grenade_time = 500 - grenade_power
			throw_grenade(right_stick_direction,grenade_time)
	
	var input_detected = false
	if Input.is_action_pressed("p1_left" , player_id):
		velocity.x -= 5
		input_detected = true
	if Input.is_action_pressed("p1_right" , player_id):
		velocity.x += 5
		input_detected = true
	
	var y_input = Input.get_joy_axis(player_id,JOY_AXIS_1)
	
	var joy_input = Input.get_joy_axis(player_id,JOY_AXIS_0)
	
	
	if Input.is_action_pressed("p1_up"):
		y_input = -1
	elif Input.is_action_pressed("p1_down"):
		y_input = 1
	
	if abs(joy_input) < 0.2:
		joy_input = 0
	else:
		input_detected = true
	
	velocity.x += joy_input*5
	
	if Input.is_action_just_pressed("p1_jump" , player_id):
		if is_on_floor():
			velocity.y = -jump_strength
	elif is_on_floor():
		velocity.y = move_toward(velocity.y,0,5)
	elif not on_ladder:
		velocity.y += 1
	elif abs(y_input) > 0.2:
		velocity.y = y_input*50
	else:
		velocity.y = 0
	if not input_detected:
		velocity.x = move_toward(velocity.x,0,5)


func _physics_process(delta):
	handle_input()
	velocity.x = clamp(velocity.x,-speed,speed)
	move_and_slide(velocity,Vector2.UP)

func despawn():
	queue_free()

func get_hit():
	drop_weapon()
	var corpse_instance = corpse.instance()
	get_parent().add_child(corpse_instance)
	corpse_instance.global_position = self.global_position
	corpse_instance.angular_velocity = rand_range(-5,5)
	despawn()



func throw_grenade(direction,time):
	var grenade_instance = grenade.instance()
	grenade_instance.direction = direction.normalized() * grenade_power *1000
	
	get_parent().add_child(grenade_instance)
	grenade_instance.time = time
	grenade_instance.global_position = $Handpivot/Hand.global_position
	grenade_power = 0
	grenades -= 1

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

func pickup_weapon():
	var bodies = $Area2D.get_overlapping_bodies()
	var target = null
	for item in bodies:
		if item.is_in_group("weapon"):
			target = item
			break
	
	if target:
		var picked_instance = target.spawnable.instance()
		$Handpivot/Hand.add_child(picked_instance)
		picked_instance.ammo = target.ammo
		hand_item = picked_instance
		target.queue_free()
	

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




