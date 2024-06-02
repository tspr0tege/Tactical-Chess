extends Node2D

var coords
var tenant

func _on_texture_button_pressed():
	var GAME_BOARD = find_parent("GameBoard")
	var PIECE = GAME_BOARD.MOVING_PIECE
	
	print("Moving " + PIECE.color +" "+ PIECE.type_of_piece + " to " + str(coords))
	GAME_BOARD.boardTiles[PIECE.coords.x][PIECE.coords.y].tenant = null
	PIECE.coords = coords
	tenant = PIECE
	PIECE.moveTo(self.position)
	
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.MOVING_PIECE = null
