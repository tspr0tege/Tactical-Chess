extends Node2D

@onready var SCENE_LOADER = find_parent("Scene Loader")

func _on_restart_button_down():
	if SCENE_LOADER != null:
		print("Starting new game!")
		find_parent("Scene Loader").load_new_game()
	else:
		print("No Scene Loader is present")


func _on_quit_button_down():	
	if SCENE_LOADER != null:
		print("Exiting to main menu")
		find_parent("Scene Loader").load_main_menu()
	else:
		print("No Scene Loader is present")

func gameOver(winner):
	pass
