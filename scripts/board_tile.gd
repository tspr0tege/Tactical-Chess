extends Node2D

var coords
var tenant
var GAME_BOARD

func _ready():
	GAME_BOARD = find_parent("GameBoard")	

func _on_texture_button_pressed():
	var PIECE = GAME_BOARD.MOVING_PIECE
	
	print("Moving " + PIECE.color +" "+ PIECE.type_of_piece + " to " + str(coords))
	if GAME_BOARD.creatingPiece:
		GAME_BOARD.player[GAME_BOARD.playerTurn].points -= GAME_BOARD.pieceValues[PIECE.type_of_piece]
		GAME_BOARD.buyAvailable = false
	else:
		GAME_BOARD.boardTiles[PIECE.coords.x][PIECE.coords.y].tenant = null
		GAME_BOARD.moveAvailable = false
		PIECE.first_move = false
	PIECE.coords = coords
	tenant = PIECE
	PIECE.moveTo(self.position)
	
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.MOVING_PIECE = null
	GAME_BOARD.creatingPiece = false
