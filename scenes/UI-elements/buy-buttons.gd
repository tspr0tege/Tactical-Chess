extends PanelContainer

signal buy_button_pressed(piece_name)

func _handle_buy_button_input(piece_name):
	buy_button_pressed.emit(piece_name)
