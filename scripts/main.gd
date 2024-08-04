extends Node2D

@onready var SCENE_LOADER = find_parent("Scene Loader")

func _on_restart_button_down():
	if SCENE_LOADER == null:
		print("No Scene Loader is present")
		return 
	
	print("Starting new game!")
	SCENE_LOADER.load_new_game()


func _on_quit_button_down():
	if SCENE_LOADER == null:
		print("No Scene Loader is present")
		return 
	
	print("Starting new game!")
	SCENE_LOADER.load_main_menu()
