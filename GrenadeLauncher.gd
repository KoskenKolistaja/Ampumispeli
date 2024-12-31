extends Area2D


export var propelled_grenade: PackedScene
export var droppable: PackedScene

var ammo = 6

var strength = 15

var released = true

func shoot():
	print(released)
	if released:
		if ammo > 0:
			var shooting_direction = $right.global_position - self.global_position
			var bullet_instance = propelled_grenade.instance()
			get_tree().root.get_child(0).add_child(bullet_instance)
			bullet_instance.global_position = $Barrel.global_position
			bullet_instance.direction = shooting_direction
			bullet_instance.speed = strength
			released = false
			$AudioStreamPlayer.pitch_scale = rand_range(0.95,1.05)
			$AudioStreamPlayer.play()
			ammo -= 1
		else:
			$AudioStreamPlayer2.play()
			released = false

func release_trigger():
	released = true
