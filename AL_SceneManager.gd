extends Node

const MAIN_MENU := "res://scenes/main-menu/main_menu.tscn"
const LOCAL_GAME := "res://scenes/main.tscn"
const ONLINE_GAME := "res://scenes/websocket_multiplayer_main.tscn"

func load_new_local_game():
	var scene = load(LOCAL_GAME)
	Data.is_multiplayer_game = false
	get_tree().change_scene_to_packed(scene)

func load_main_menu():
	var scene = load(MAIN_MENU)
	get_tree().change_scene_to_packed(scene)

func load_new_online_game():
	var scene = load(ONLINE_GAME)
	Data.is_multiplayer_game = true
	get_tree().change_scene_to_packed(scene)
