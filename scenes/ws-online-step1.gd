extends PanelContainer


signal step_one_input(choice)


func _create_room():
	step_one_input.emit("CREATE")


func _join_room():
	step_one_input.emit("JOIN")


func _cancel_online():
	SceneManager.load_main_menu()
