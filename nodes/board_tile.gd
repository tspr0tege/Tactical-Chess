extends Node2D

var coords
var tenant

signal board_tile_button_pressed(node)

func _on_texture_button_pressed():
	board_tile_button_pressed.emit(self)

