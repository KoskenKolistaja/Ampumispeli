extends Particles2D


func _ready():
	emitting = true
	$Smoke.emitting = true
	MetaData.play_explosion()
	MetaData.shake_camera()


func _on_Timer_timeout():
	queue_free()
