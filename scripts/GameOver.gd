extends Panel

@onready var SCENE_LOADER = find_parent("Scene Loader")

func _on_restart_button_down():
	if SCENE_LOADER != null:
		SCENE_LOADER.load_new_game()
	else:
		print("No Scene Loader Present")


func _on_quit_button_down():
	if SCENE_LOADER != null:
		SCENE_LOADER.load_main_menu()
	else:
		print("No Scene Loader Present")
