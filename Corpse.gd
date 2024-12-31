extends RigidBody2D


func _ready():
	$AudioStreamPlayer.play()

func explode(explosion_position,explosion_strength):
	var direction = (self.global_position - explosion_position).normalized()
	apply_central_impulse(direction * explosion_strength)
	if explosion_position.x - global_position.x > 0:
		angular_velocity = -5
	else:
		angular_velocity = 5


func _on_Timer_timeout():
	queue_free()
