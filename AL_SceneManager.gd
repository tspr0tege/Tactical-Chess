extends Node

const MAIN_MENU := "res://scenes/main_menu.tscn"
const LOCAL_GAME := "res://scenes/main.tscn"

func load_new_local_game():
	var scene = load(LOCAL_GAME)
	get_tree().change_scene_to_packed(scene)

func load_main_menu():
	var scene = load(MAIN_MENU)
	get_tree().change_scene_to_packed(scene)
