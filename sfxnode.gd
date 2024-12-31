extends AudioStreamPlayer

func _on_sfxnode_finished():
	queue_free()
