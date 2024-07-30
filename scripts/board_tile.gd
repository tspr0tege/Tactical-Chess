extends Node2D

var coords
var tenant
var GAME_BOARD

func _ready():
	GAME_BOARD = find_parent("GameBoard")	

func _on_texture_button_pressed():
	var PIECE = GAME_BOARD.MOVING_PIECE
	var currentPlayer = GAME_BOARD.player[GAME_BOARD.playerTurn[0]]
	var opposingPlayer = GAME_BOARD.player[GAME_BOARD.playerTurn[1]]
	
	print("Moving " + PIECE.color +" "+ PIECE.type_of_piece + " to " + str(coords))
	if GAME_BOARD.creatingPiece:
		currentPlayer.points -= GAME_BOARD.pieceValues[PIECE.type_of_piece]
		currentPlayer.pieces.push_back(PIECE)
		GAME_BOARD.buyAvailable = false
	else:
		GAME_BOARD.boardTiles[PIECE.coords.x][PIECE.coords.y].tenant = null
		GAME_BOARD.moveAvailable = false
		PIECE.first_move = false
	PIECE.coords = coords
	PIECE.moveTo(self.position)
	
	#If there is a piece
	if is_instance_valid(tenant):
		#Gain points
		currentPlayer.points += GAME_BOARD.pieceValues[tenant.type_of_piece]
		#Remove piece from game and array
		opposingPlayer.pieces.erase(tenant)
		tenant.queue_free()
		
	tenant = PIECE
	
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.MOVING_PIECE = null
	GAME_BOARD.creatingPiece = false
