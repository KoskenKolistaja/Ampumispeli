extends Particles2D


func _ready():
	emitting = true
	$Smoke.emitting = true


func _on_Timer_timeout():
	queue_free()
