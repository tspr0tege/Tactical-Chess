extends Node2D

var coords
var tenant

signal board_tile_button_pressed(node)


func _on_texture_button_pressed():
	board_tile_button_pressed.emit(self)


func toggle_button_on():
	$TextureButton.visible = true
	$TextureButton/Polygon2D.color = "#ff7700" if is_instance_valid(tenant) else "#00ff00"
	


func toggle_button_off():
	$TextureButton.visible = false
