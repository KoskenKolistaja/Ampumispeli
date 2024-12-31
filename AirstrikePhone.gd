extends Area2D

export var airstrike: PackedScene
export var droppable: PackedScene

var ammo = 1







func shoot():
	if ammo > 0:
		var airstrike_instance = airstrike.instance()
		get_tree().root.get_child(0).add_child(airstrike_instance)
		ammo -= 1
