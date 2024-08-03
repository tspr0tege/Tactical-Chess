extends MenuButton

func _on_toggled(button_pressed):
	$PopupMenu.visible = button_pressed
