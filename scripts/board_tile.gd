extends Node2D

var coords
var tenant
@onready var GAME_BOARD = find_parent("GameBoard")

func _on_texture_button_pressed():
	var PIECE = GAME_BOARD.MOVING_PIECE
	var currentPlayer = GAME_BOARD.player[0]
	var opposingPlayer = GAME_BOARD.player[1]
	#print(str(PIECE.coords == null))
	
	print("Moving " + PIECE.color +" "+ PIECE.type_of_piece + " to " + str(coords))
	
	if PIECE.type_of_piece == "King" and PIECE.first_move:
		GAME_BOARD.boardTiles[PIECE.coords.x][PIECE.coords.y].queue_free()
	
	#Moving a newly deployed piece onto the board
	if PIECE.coords == null:
		#currentPlayer.points -= GAME_BOARD.pieceValues[PIECE.type_of_piece]
		GAME_BOARD.updatePoints(-GAME_BOARD.pieceValues[PIECE.type_of_piece])
		currentPlayer.pieces.push_back(PIECE)
		GAME_BOARD.updateBuyAvailable(false)
	else:
		GAME_BOARD.boardTiles[PIECE.coords.x][PIECE.coords.y].tenant = null
		GAME_BOARD.updateMoveAvailable(false)
		PIECE.first_move = false
	
	PIECE.coords = coords
	PIECE.z_index = self.z_index + 1
	PIECE.moveTo(self.position)
	
	#If there is a piece
	if is_instance_valid(tenant):
		if tenant.type_of_piece == "King":
			#current player wins
			GAME_BOARD.game_over()
		else:
			#currentPlayer.points += GAME_BOARD.pieceValues[tenant.type_of_piece]
			GAME_BOARD.updatePoints(GAME_BOARD.pieceValues[tenant.type_of_piece])
			opposingPlayer.pieces.erase(tenant)
			tenant.queue_free()
		
	tenant = PIECE
	
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.MOVING_PIECE = null
