extends Node2D

var coords = []
var tenant

func _on_texture_button_pressed():
	print("Board Tile pressed. Coords: " + str(coords))
