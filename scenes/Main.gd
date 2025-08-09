class_name Main extends Node2D

@export var NE_CONTAINER : Control
@export var BOTTOM_PANEL : Control
@export var GAME_BOARD : Node2D
@export var SACRIFICE_PAWN_BUTTON : Button
@export var WHITE_POINTS_CONTAINER : Container
@export var BLACK_POINTS_CONTAINER : Container
@export var BUY_BUTTONS_CONTAINER : Container

@onready var WHITE_POINTS_LABEL = WHITE_POINTS_CONTAINER.find_child("WhitePointsLabel")
@onready var BLACK_POINTS_LABEL = BLACK_POINTS_CONTAINER.find_child("BlackPointsLabel")

var ChessPiece = preload("res://nodes/chess-piece/chess_piece.tscn")

var players = {
	"White": {
		"color": "White",
		"pieces": [],
		"points": 3,
		"spawn_columns": [1, 2],
		"button_theme": "res://themes/white_player_turn_theme.tres",
	},
	"Black": {
		"color": "Black",
		"pieces": [],
		"points": 3,
		"spawn_columns": [5, 6],
		"button_theme": "res://themes/black_player_turn_theme.tres",
	},
}


func _ready():
	players.White.points_display = WHITE_POINTS_LABEL
	players.Black.points_display = BLACK_POINTS_LABEL
	WHITE_POINTS_LABEL.text = str(players.White.points)
	BLACK_POINTS_LABEL.text = str(players.Black.points)
	
	for button in BUY_BUTTONS_CONTAINER.get_children():
		var piece_name = button.name.substr(0, button.name.length() - 6)
		var cost = Data.pieceValues[piece_name]
		button.disabled = players[Data.player_turn].points < cost
		button.tooltip_text = "%s: %s %s" % [piece_name, cost, " point" if cost == 1 else " points"]
	
	initialize_turn()


func update_player_points(value):
	#check for point-based win
	players[Data.player_turn].points += value
	players[Data.player_turn].points_display.text = str(players[Data.player_turn].points)
	
	for button in BUY_BUTTONS_CONTAINER.get_children():
		var piece_name = button.name.substr(0, button.name.length() - 6)
		button.disabled = players[Data.player_turn].points < Data.pieceValues[piece_name]


func _handle_buy_button_pressed(piece_name: String):
	SACRIFICE_PAWN_BUTTON.visible = false
	GAME_BOARD.PENDING_ACTION = create_new_piece.bind(piece_name)
	GAME_BOARD.activate_spawn_columns(players[Data.player_turn].spawn_columns)


func create_new_piece(tile, piece_name, color = Data.player_turn):
	var player = players[color]
	var newChessPiece = ChessPiece.instantiate()
	newChessPiece.createPiece(color, piece_name)
	if piece_name != "King":
		update_player_points(-Data.pieceValues[piece_name])
	newChessPiece.connect("chesspiece_clicked", GAME_BOARD._handle_chesspiece_clicked)
	players[color].pieces.push_back(newChessPiece)
	newChessPiece.moveTo(tile, true)
	GAME_BOARD.add_child(newChessPiece)
	GAME_BOARD.buyAvailable = false
	for button in BUY_BUTTONS_CONTAINER.get_children():
		button.disabled = true
	GAME_BOARD.PENDING_ACTION = null


func _handle_considering_move(piece):
	SACRIFICE_PAWN_BUTTON.visible = false
	GAME_BOARD.PENDING_ACTION = move_piece.bind(piece)


func move_piece(tile, piece): #piece will have from coords, tile will have to coords
	
	if piece.type_of_piece == "King" and piece.first_move:
		GAME_BOARD.boardTiles[piece.coords.x][piece.coords.y].queue_free()
	else:
		GAME_BOARD.boardTiles[piece.coords.x][piece.coords.y].tenant = null
	
	GAME_BOARD.moveAvailable = false
	piece.first_move = false	
	
	#If there is a piece - capture it
	if is_instance_valid(tile.tenant):
		if tile.tenant.type_of_piece == "King":
			print(str(piece.color) + " Wins!")
		else:
			update_player_points(Data.pieceValues[tile.tenant.type_of_piece])
			players[tile.tenant.color].pieces.erase(tile.tenant)
			tile.tenant.queue_free()
	
	piece.moveTo(tile)
	GAME_BOARD.PENDING_ACTION = null


func _pawn_sacrifice_possible(piece):
	SACRIFICE_PAWN_BUTTON.visible = true
	SACRIFICE_PAWN_BUTTON.connect("button_up", sacrifice_pawn.bind(piece))


func sacrifice_pawn(piece):
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.moveAvailable = false
	update_player_points(2)
	players[Data.player_turn].pieces.erase(piece)
	piece.queue_free()
	SACRIFICE_PAWN_BUTTON.visible = false
	GAME_BOARD.PENDING_ACTION = null
	SACRIFICE_PAWN_BUTTON.disconnect("button_up", sacrifice_pawn)


func _handle_end_turn():
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.NEW_PIECE = null
	
	#Initialize new turn
	if Data.player_turn == "White":
		Data.player_turn = "Black"
	else:
		Data.player_turn = "White"
	update_player_points(1)
	initialize_turn()


func initialize_turn():
	NE_CONTAINER.theme = load(players[Data.player_turn].button_theme)
	BOTTOM_PANEL.theme = load(players[Data.player_turn].button_theme)
	GAME_BOARD.moveAvailable = true
	GAME_BOARD.buyAvailable = true
	
	var all_pieces = get_tree().get_nodes_in_group("Chess Pieces")
	for piece in all_pieces:
		var TEXTURE_BUTTON = piece.get_node("TextureButton")
		if piece.color != Data.player_turn:
			TEXTURE_BUTTON.disabled = true
			TEXTURE_BUTTON.set_mouse_filter(2)
		else:
			TEXTURE_BUTTON.disabled = false
			TEXTURE_BUTTON.set_mouse_filter(0)

