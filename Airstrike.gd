extends Node2D

export var propelled_grenade: PackedScene

var horizontal = -1000


func spawn_rocket():
	var rocket_instance = propelled_grenade.instance()
	get_parent().add_child(rocket_instance)
	rocket_instance.global_position = Vector2(horizontal,0)
	rocket_instance.direction = Vector2(1,1)
	rocket_instance.speed = 15
	horizontal += 100


func _on_Timer2_timeout():
	$Timer.stop()
	$Timer2.stop()


func _on_Timer_timeout():
	spawn_rocket()


func _on_AudioStreamPlayer_finished():
	$Timer.start()
	$AudioStreamPlayer2.play()


func _on_AudioStreamPlayer2_finished():
	queue_free()
