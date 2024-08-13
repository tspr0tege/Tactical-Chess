extends Node

func _ready():
	load_main_menu()

func load_new_game():
	unloadChildren()
	var gameScene = load("res://scenes/main.tscn").instantiate()
	gameScene.name = "Main"
	add_child(gameScene, true)

func load_main_menu():
	unloadChildren()
	var mainMenu = load("res://scenes/main_menu.tscn").instantiate()
	add_child(mainMenu)

func unloadChildren():
	for child in self.get_children():
		child.name = str(randi())
		child.queue_free()
