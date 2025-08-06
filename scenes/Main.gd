class_name Main extends Node2D

@onready var NE_CONTAINER = %NEContainer
@onready var BOTTOM_PANEL = %BottomPanel
@onready var BUY_BUTTONS_CONTAINER = %BuyButtonsContainer

func _ready():
	Data.players[0].update_points = _update_white_points
	Data.players[1].update_points = _update_black_points
	
	for button in %BuyButtonsContainer.get_children():
		var piece_name = button.name.substr(0, button.name.length() - 6)
		var cost = Data.pieceValues[piece_name]
		button.disabled = Data.players[0].points < cost
		button.tooltip_text = "%s: %s %s" % [piece_name, cost, " point" if cost == 1 else " points"]


func _on_restart_button_down():
	SceneManager.load_new_local_game()


func _on_quit_button_down():
	SceneManager.load_main_menu()


func _update_black_points():
	%BlackPointsLabel.text = str(Data.players[1].points)


func _update_white_points():
	%WhitePointsLabel.text = str(Data.players[0].points)


func _handle_update_player_points(value):
	Data.players[0].points += value
	Data.players[0].update_points.call()
	#points_display.text = str(player[0].points)
	#player[1].points_display.text = "[center]" + str(player[1].points) + "[/center]"
	for button in BUY_BUTTONS_CONTAINER.get_children():
		var piece_name = button.name.substr(0, button.name.length() - 6)
		button.disabled = Data.players[0].points < Data.pieceValues[piece_name]


func _handle_remove_piece(player, piece):
	Data.players[player].pieces.erase(piece)


func _handle_buy_button_pressed(piece_name: String):
	%GameBoard._on_buy_piece_button_up(Data.players[0], piece_name)


func _handle_end_turn():
	%GameBoard.resetMoveTiles()
	%GameBoard.clearBuyBox()
	
	if Data.players[0].points >= 20:
		#game_over()
		return
	
	Data.players[0].pieces[-1].is_moveable = true
		
	#Initialize new turn
	Data.players.reverse()
	initialize_turn()


func initialize_turn():
	NE_CONTAINER.theme = load(Data.players[0].button_theme)
	BOTTOM_PANEL.theme = load(Data.players[0].button_theme)
	%GameBoard.updateMoveAvailable(true)
	%GameBoard.updateBuyAvailable(true)
	_handle_update_player_points(1)
	
	for piece in Data.players[0].pieces:
		var TEXTURE_BUTTON = piece.get_node("TextureButton")
		TEXTURE_BUTTON.disabled = false
		TEXTURE_BUTTON.set_mouse_filter(0)
	
	for piece in Data.players[1].pieces:
		var TEXTURE_BUTTON = piece.get_node("TextureButton")
		TEXTURE_BUTTON.disabled = true
		TEXTURE_BUTTON.set_mouse_filter(2)


func _handle_place_new_piece(piece, _coords):
	var target_player = 0 if piece.color == Data.players[0].color else 1
	Data.players[target_player].pieces.push_back(piece)


func _handle_show_sacrifice_pawn_button(switch: bool):
	%SacrificePawnButton.visible = switch


func _handle_sacrifice_pawn_button_pressed():
	%GameBoard.sacrificePawn()
	pass # Replace with function body.
