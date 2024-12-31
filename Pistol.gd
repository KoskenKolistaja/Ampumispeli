extends Area2D

var strength = 12

export var bullet: PackedScene
export var muzzle_flash: PackedScene
export var droppable: PackedScene

var released = true



var ammo = 14


func shoot():
	if released:
		if ammo > 0:
			var shooting_direction = $right.global_position - self.global_position
			var bullet_instance = bullet.instance()
			get_tree().root.get_child(0).add_child(bullet_instance)
			bullet_instance.global_position = $Barrel.global_position
			bullet_instance.direction = shooting_direction
			bullet_instance.speed = strength
			released = false
			$AudioStreamPlayer.pitch_scale = rand_range(0.95,1.05)
			$AudioStreamPlayer.play()
			ammo -= 1
			spawn_flash()
		else:
			$AudioStreamPlayer2.play()
			released = false

func release_trigger():
	released = true

func spawn_flash():
	var flash_instance = muzzle_flash.instance()
	get_tree().root.get_child(0).add_child(flash_instance)
	flash_instance.global_position = $Barrel.global_position
