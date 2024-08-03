extends Node

@onready var SCENE_LOADER = find_parent("Scene Loader")

func _on_new_game_pressed():
	if SCENE_LOADER != null:
		print("Starting new game!")
		find_parent("Scene Loader").load_new_game()
	else:
		print("No Scene Loader is present")
