extends MarginContainer


func _ready():
	if Data.is_multiplayer_game:
		$MenuButton/PopupMenu/MarginContainer/VBoxContainer/Restart.disabled = true


func _on_menu_toggled(boolean):
	$MenuButton/PopupMenu.visible = boolean


func _handle_menu_input(input: String):
	match input:
		"RESTART":
			SceneManager.load_new_local_game()
		"QUIT":
			SceneManager.load_main_menu()
		_:
			print("Pause Menu input not recognized")

