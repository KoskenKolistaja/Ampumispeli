extends RigidBody2D

var direction = Vector2.ZERO
var strength = 100
var time = 1



export var explosion: PackedScene



func _ready():
	angular_velocity = rand_range(-20,20)
	apply_central_impulse(direction*30)


func explode():
	var bodies = $Area2D.get_overlapping_bodies()
	var explosion_instance = explosion.instance()
	get_parent().add_child(explosion_instance)
	explosion_instance.global_position = self.global_position
	

	for body in bodies:
		if body.is_in_group("player") or body.is_in_group("corpse"):
			if body.has_method("explode"):
				body.explode(self.global_position,strength)


func _on_Timer_timeout():
	explode()
	queue_free()



