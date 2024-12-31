extends Node


export var sfx_node: PackedScene

onready var audio_players = []

onready var explosion_sounds = [
preload("res://sfx/explosions/grenade_1.mp3"),
preload("res://sfx/explosions/grenade_2.mp3"),
preload("res://sfx/explosions/grenade_3.mp3"),
preload("res://sfx/explosions/grenade_4.mp3"),
preload("res://sfx/explosions/grenade_5.mp3"),
preload("res://sfx/explosions/grenade_6.mp3"),
preload("res://sfx/explosions/grenade_7.mp3"),
]



func _ready():
	MetaData.audio_player = self



func play_explosion():
	var random_number = int(rand_range(0, explosion_sounds.size()))
	var sfx_node_instance = sfx_node.instance()
	add_child(sfx_node_instance)
	sfx_node_instance.stream = explosion_sounds[random_number]
	sfx_node_instance.play()




#func find_empty_player():
#	if not audio_players:
#		print("returned")
#		return
#
#	var empty = audio_players[0]
#	print(audio_players)
#	for item in audio_players:
#		if not item.playing:
#			empty = item
#			break
#	return empty
