extends Node2D

export var grenade: PackedScene
export var bullet: PackedScene
export var player: PackedScene
export var enemy: PackedScene


export var smg: PackedScene
export var ar: PackedScene
export var grenade_launcher: PackedScene
export var airstrike: PackedScene



var spawn_list = []

var levels = [
	preload("res://Level1.tscn"),
	preload("res://Level2.tscn")]

var player_weapons = []

onready var spawn_node = $SpawnBlock/PlayerSpawn


func _ready():
	create_level()
	randomize()
	$CanvasLayer2/Label.text = str(MetaData.level)


func _physics_process(delta):
	if Input.is_action_just_pressed("spacebar"):
		next_level()

func player_died(object):
	var players = get_tree().get_nodes_in_group("player")
	
	players.erase(object)
	if players:
		pass
	else:
		game_over()


func game_over():
	MetaData.level = 1

func create_level():
	$CanvasLayer2/Label.text = str(MetaData.level)
	spawn_level()
	spawn_enemies()
	spawn_players()
	spawn_weapons()

func spawn_level():
	var rand_index:int = randi() % levels.size()
	var level_instance = levels[rand_index].instance()
	add_child(level_instance)
	spawn_list.append(level_instance)

func spawn_weapons():
	var spawners = get_tree().get_nodes_in_group("weaponspawner")
	
	for item in spawners:
		if 0.2 < rand_range(0,1):
			spawn_weapon(item.global_position)


func spawn_weapon(spawn_position):
	var weapon = null
	
	var likelihood = 0
	
	likelihood += MetaData.level/100
	likelihood = clamp(likelihood,0,0.3)
	
	if (0.1 + likelihood) > 0.5:
		weapon = airstrike
	elif 0.1 + likelihood > rand_range(0,1):
		weapon = grenade_launcher
	elif 0.5 > rand_range(0,1):
		weapon = smg
	else:
		weapon = ar
	
	var spawned = weapon.instance()
	spawned.global_position = spawn_position
	add_child(spawned)

func spawn_enemies():
	var amount = 0
	var enemy_spawners = get_tree().get_nodes_in_group("enemyspawner")
	for item in enemy_spawners:
		if amount < MetaData.level and rand_range(0,1) < 0.5:
			spawn_enemy(item.global_position)
			amount += 1
	

func spawn_enemy(spawn_position):
	var enemy_instance = enemy.instance()
	add_child(enemy_instance)
	enemy_instance.global_position = spawn_position
	spawn_list.append(enemy_instance)
	


func spawn_players():
	var index = 0
	for item in MetaData.players:
		spawn_player(index)
		index += 1


func spawn_player(index):
	var player_instance = player.instance()
	add_child(player_instance)
	player_instance.global_position = spawn_node.global_position
	player_instance.player_id = index
	spawn_list.append(player_instance)



func next_level():
	MetaData.level += 1
	clear_spawnlist()
	create_level()
	




func clear_spawnlist():
	for item in spawn_list:
		if is_instance_valid(item):
			item.queue_free()
	spawn_list.clear()
	var weapons = get_tree().get_nodes_in_group("weapon")
	for item in weapons:
		item.queue_free()
	
	var deleted = get_tree().get_nodes_in_group("cleared")
	
	for item in deleted:
		item.queue_free()
	


func spawn_bullet():
	var bullet_instance = bullet.instance()
	add_child(bullet_instance)
	bullet_instance.direction = get_global_mouse_position().normalized()

func spawn_explosion():
	var grenade_instance = grenade.instance()
	add_child(grenade_instance)
	grenade_instance.global_position = get_global_mouse_position()


func _on_VictoryArea_body_entered(body):
	if body.is_in_group("player"):
		next_level()



