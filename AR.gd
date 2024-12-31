extends Area2D


var strength = 20

export var bullet: PackedScene
export var muzzle_flash: PackedScene

export var droppable: PackedScene

var released = true



var ammo = 20


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
			$Timer.start()
			spawn_flash()
		else:
			$AudioStreamPlayer2.play()
			released = false
			$Timer.stop()

func spawn_flash():
	var flash_instance = muzzle_flash.instance()
	get_tree().root.get_child(0).add_child(flash_instance)
	flash_instance.global_position = $Barrel.global_position


func release_trigger():
	released = true


func _on_Timer_timeout():
	released = true
