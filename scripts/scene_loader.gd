extends Node

func _ready():
	load_main_menu()

func load_new_game():
	unloadChildren()
	var gameScene = load("res://scenes/main.tscn").instantiate()
	add_child(gameScene)

func load_main_menu():
	unloadChildren()
	var mainMenu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(mainMenu)

func unloadChildren():
	for child in self.get_children():
		child.queue_free()
