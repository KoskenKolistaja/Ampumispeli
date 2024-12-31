extends RigidBody2D


var spawnable

var ammo = 6

func _ready():
	spawnable = MetaData.grenade_launcher



func _on_Timer_timeout():
	queue_free()


func _on_Timer2_timeout():
	if ammo < 1:
		$Timer.start()
