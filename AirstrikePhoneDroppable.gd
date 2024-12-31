extends RigidBody2D


var spawnable

var ammo = 1

func _ready():
	spawnable = MetaData.airstrike



func _on_Timer_timeout():
	queue_free()


func _on_Timer2_timeout():
	if ammo < 1:
		$Timer.start()
