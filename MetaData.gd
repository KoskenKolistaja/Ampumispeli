extends Node

var players = 2
var level = 1

var audio_player
var camera

var pistol = preload("res://Pistol.tscn")
var smg = preload("res://SMG.tscn")
var ar = preload("res://AR.tscn")
var grenade_launcher = preload("res://GrenadeLauncher.tscn")
var airstrike = preload("res://AirstrikePhone.tscn")


func shake_camera():
	camera.apply_shake()

func play_explosion():
	audio_player.play_explosion()
