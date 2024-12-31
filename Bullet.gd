extends Area2D


var direction = Vector2.RIGHT
var speed = 15

export var decal: PackedScene

func _physics_process(delta):
	global_position += direction * speed

func spawn_decal():
	var decal_instance = decal.instance()
	get_tree().root.get_child(0).add_child(decal_instance)
	decal_instance.global_position = self.global_position

func _on_Bullet_body_entered(body):
	if body.is_in_group("hittable"):
		if body.has_method("get_hit"):
			body.get_hit()
			queue_free()
	elif body.collision_layer == 2:
		pass
	else:
		spawn_decal()
		queue_free()
