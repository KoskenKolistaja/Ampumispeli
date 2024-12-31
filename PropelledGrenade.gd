extends Area2D

export var explosion: PackedScene
var direction = Vector2.RIGHT
var strength = 100
var speed = 0.01


func _physics_process(delta):
	global_position += direction * speed *0.4
	direction += Vector2(0,0.01)
	rotation = deg2rad(rad2deg(direction.angle())+90)

func _on_PropelledGrenade_body_entered(body):
	explode()
	queue_free()


func explode():
	var bodies = $Area2D.get_overlapping_bodies()
	var explosion_instance = explosion.instance()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = self.global_position
	

	for body in bodies:
		if body.is_in_group("hittable") or body.is_in_group("corpse"):
			if body.has_method("explode"):
				body.explode(self.global_position,strength)


func _on_Timer_timeout():
	print("propelled grenade queued free!")
	queue_free()
