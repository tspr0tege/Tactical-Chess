extends Node2D

var coords
var tenant
var GAME_BOARD

func _ready():
	GAME_BOARD = find_parent("GameBoard")	

func _on_texture_button_pressed():
	var PIECE = GAME_BOARD.MOVING_PIECE
	
	print("Moving " + PIECE.color +" "+ PIECE.type_of_piece + " to " + str(coords))
	if not GAME_BOARD.creatingPiece:
		GAME_BOARD.boardTiles[PIECE.coords.x][PIECE.coords.y].tenant = null
		PIECE.first_move = false
	PIECE.coords = coords
	tenant = PIECE
	PIECE.moveTo(self.position)
	
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.MOVING_PIECE = null
	GAME_BOARD.creatingPiece = false
