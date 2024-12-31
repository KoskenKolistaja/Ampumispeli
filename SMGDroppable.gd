extends RigidBody2D


var spawnable

var ammo = 30

func _ready():
	spawnable = MetaData.smg



func _on_Timer_timeout():
	queue_free()


func _on_Timer2_timeout():
	if ammo < 1:
		$Timer.start()
