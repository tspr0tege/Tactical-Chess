extends Node2D

const BoardTile = preload("res://nodes/board_tile.tscn")
const ChessPiece = preload("res://nodes/chess-piece/chess_piece.tscn")

signal place_new_piece(piece, coords)
signal update_player_points(amt)
signal remove_piece(piece)
signal end_turn
signal show_sacrifice_pawn(switch)

var boardTiles = []
var MOVING_PIECE = null
var moveAvailable = true
var buyAvailable = true

func _ready(): #create initial board state
	var isACorner = func (x, y):
		return (x == 0 or x == 7) and (y == 0 or y == 2)
	
	for x in range(8):
		var newRow = []
		for y in range(3):
			if (isACorner.call(x, y)):
				newRow.push_back(null)
				continue
			
			var newBoardTile = BoardTile.instantiate()
			newBoardTile.position = Vector2(x, y) * 64
			newBoardTile.z_index = 10 + (y * 10)
			newBoardTile.coords = Vector2(x, y)
			newBoardTile.connect("board_tile_button_pressed", _handle_board_tile_button_clicked)
			
			if (x + y) % 2 == 0:
				newBoardTile.get_node("Sprite2D").frame = randi_range(4, 7)
			else:
				newBoardTile.get_node("Sprite2D").frame = randi_range(0, 3)
			newBoardTile.get_node("Sprite2D").flip_h = randi() % 2 == 0
			add_child(newBoardTile)
			newRow.push_back(newBoardTile)
			
			# Place Kings
			if x == 0 or x == 7:
				var newChessPiece = ChessPiece.instantiate()
				var color = "White" if (x == 0) else "Black"
				newChessPiece.createPiece(color, "King")
				newChessPiece.position = newBoardTile.position
				newChessPiece.coords = Vector2(x, y)
				newChessPiece.is_moveable = true
				newChessPiece.connect("chesspiece_clicked", _handle_chesspiece_clicked)
				add_child(newChessPiece)
				#player[x if x == 0 else 1].pieces.push_back(newChessPiece)
				place_new_piece.emit(newChessPiece, Vector2(x, y))
				newBoardTile.tenant = newChessPiece
		
		boardTiles.push_back(newRow)

func resetMoveTiles():
	for x in boardTiles:
		for tile in x:
			if tile != null:
				tile.get_node("TextureButton").visible = false
				tile.get_node("TextureButton/Polygon2D").color = "#00ff00"


func clearBuyBox():
	if is_instance_valid(MOVING_PIECE) and MOVING_PIECE.coords == null:
		MOVING_PIECE.queue_free()
		MOVING_PIECE = null


func updateBuyAvailable(boolean):
	buyAvailable = boolean


func updateMoveAvailable(boolean):
	moveAvailable = boolean


func sacrificePawn():
	resetMoveTiles()
	updateMoveAvailable(false)
	update_player_points.emit(2)
	remove_piece.emit(0, MOVING_PIECE)
	show_sacrifice_pawn.emit(false)
	MOVING_PIECE.queue_free()


func getMovementTiles(type_of_piece, color, coords, first_move = false):
	var tilesArray = []
	
	var isValidTile = func(target_coords):
		# Target is off board on left or right
		if target_coords.x < 0 or target_coords.x > 7: return false
		# Target is off board on top or bottom
		if target_coords.y < 0 or target_coords.y > 2: return false
		
		var boardTile = boardTiles[target_coords.x][target_coords.y]
		# Check for corners (missing values in array)
		if boardTile == null: return false
		# Check for same team piece
		if is_instance_valid(boardTile.tenant) and boardTile.tenant.color == color: return false
		
		return true

	var getCrossMovementTiles = func():	
		# right
		for x in range(8 - coords.x):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(x, 0)):
				tilesArray.push_back(boardTiles[coords.x + x][coords.y])
				if is_instance_valid(tilesArray[-1].tenant): break
			else: break
			
		# down
		for x in range(3 - coords.y):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(0, x)):
				tilesArray.push_back(boardTiles[coords.x][coords.y + x])
				if is_instance_valid(tilesArray[-1].tenant): break
			else: break
			
		# left
		for x in range(coords.x + 1):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(-x, 0)):
				tilesArray.push_back(boardTiles[coords.x - x][coords.y])
				if is_instance_valid(tilesArray[-1].tenant): break
			else: break
			
		# up
		for x in range(coords.y + 1):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(0, -x)):
				tilesArray.push_back(boardTiles[coords.x][coords.y - x])
				if is_instance_valid(tilesArray[-1].tenant): break
			else: break

	var getDiagonalMovementTiles = func():		
		# +/+ SouthEast
		for x in range(3 - coords.y):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(x, x)):
				tilesArray.push_back(boardTiles[coords.x + x][coords.y + x])
				if is_instance_valid(tilesArray[-1].tenant): break
			else: break
			
		# +/- NorthEast
		for x in range(coords.y + 1):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(x, -x)):
				tilesArray.push_back(boardTiles[coords.x + x][coords.y - x])
				if is_instance_valid(tilesArray[-1].tenant): break
			else: break
			
		# -/- NorthWest
		for x in range(coords.y + 1):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(-x, -x)):
				tilesArray.push_back(boardTiles[coords.x - x][coords.y - x])
				if is_instance_valid(tilesArray[-1].tenant): break
			else: break
			
		# -/+ SouthWest
		for x in range(3 - coords.y):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(-x, x)):
				tilesArray.push_back(boardTiles[coords.x - x][coords.y + x])
				if is_instance_valid(tilesArray[-1].tenant): break
			else: break

	match type_of_piece:
		"King":
			for x in range(3):
				for y in range(3):
					if x == 1 and y == 1: continue
					if not isValidTile.call(coords + Vector2(x-1, y-1)): continue
					tilesArray.push_back(boardTiles[coords.x+(x-1)][coords.y+(y-1)])
		"Rook":
			getCrossMovementTiles.call()
		"Pawn":
			var xDirection = 1 if color == "White" else -1
			var diagonals = [coords + Vector2(xDirection, 1), coords + Vector2(xDirection, -1)]
			
			var isAttackable = func(targetCoords):
				var tile = boardTiles[targetCoords.x][targetCoords.y]
				if not is_instance_valid(tile.tenant): return false
				if tile.tenant.color == color: return false
				return true
			
			#Check diagonal attacks
			for diagonal in diagonals:
				if isValidTile.call(diagonal) and isAttackable.call(diagonal):
					tilesArray.push_back(boardTiles[diagonal.x][diagonal.y])
			
			#Check forward movement
			if isValidTile.call(coords + Vector2(xDirection, 0)) and not is_instance_valid(boardTiles[coords.x + xDirection][coords.y].tenant): 
				tilesArray.push_back(boardTiles[coords.x + xDirection][coords.y])
				#Check second square on first move
				if first_move and isValidTile.call(coords + Vector2(xDirection * 2, 0)) and not is_instance_valid(boardTiles[coords.x + (xDirection * 2)][coords.y].tenant):
					tilesArray.push_back(boardTiles[coords.x + (xDirection * 2)][coords.y])
			
		"Knight":
			const targetTiles = [
				Vector2(2, 1), 
				Vector2(-2, 1), 
				Vector2(2, -1), 
				Vector2(-2, -1), 
				Vector2(1, 2), 
				Vector2(-1, 2), 
				Vector2(1, -2), 
				Vector2(-1, -2)
			]
			
			for target in targetTiles:
				var targetCoords = coords + target
				if isValidTile.call(targetCoords):
					tilesArray.push_back(boardTiles[targetCoords.x][targetCoords.y])
		"Bishop":
			getDiagonalMovementTiles.call()
		"Queen":
			getCrossMovementTiles.call()
			getDiagonalMovementTiles.call()
	
	return tilesArray


func _on_buy_piece_button_up(player, piece_name):
	resetMoveTiles()
	clearBuyBox()
	
	if not buyAvailable: return
	
	var emptyTiles = []
	
	for tile in boardTiles[player.spawn_columns[0]]:
		if not is_instance_valid(tile.tenant):
			emptyTiles.push_back(tile.get_node("TextureButton"))
	for tile in boardTiles[player.spawn_columns[1]]:
		if not is_instance_valid(tile.tenant):
			emptyTiles.push_back(tile.get_node("TextureButton"))
	
	if emptyTiles.size() > 0:
		print("Buying " + piece_name)
		for tile in emptyTiles: tile.visible = true
		# CREATE PIECE
		var newChessPiece = ChessPiece.instantiate()
		newChessPiece.createPiece(player.color, piece_name)
		newChessPiece.position = Vector2(32 * 7, -64)
		newChessPiece.connect("chesspiece_clicked", _handle_chesspiece_clicked)
		add_child(newChessPiece)
		MOVING_PIECE = newChessPiece
	else:
		print("No tiles available for new piece")


func game_over(winner):
	$"../CanvasLayer".visible = false
	var gameOverScreen = load("res://scenes/game_over.tscn").instantiate()
	gameOverScreen.get_node("WinnerMessage").text = "[center]" + str(winner.color).to_upper() + " IS THE WINNER!"
	get_parent().add_child(gameOverScreen)


func _handle_chesspiece_clicked(piece):
	if not Data.players[0].color == piece.color: return
	if not moveAvailable: return
	
	resetMoveTiles()
	clearBuyBox()
	
	if MOVING_PIECE == piece:
		show_sacrifice_pawn.emit(false)
		MOVING_PIECE = null
	else:
		MOVING_PIECE = piece
		
		var inBackRow = func():
			if piece.color == "Black" and piece.coords.x == 1: return true
			if piece.color == "White" and piece.coords.x == 6: return true
			return false
		
		if piece.type_of_piece == "Pawn" and inBackRow.call():
			show_sacrifice_pawn.emit(true)
		
		var movementTiles = getMovementTiles(piece.type_of_piece, piece.color, piece.coords, piece.first_move)
		for tile in movementTiles:
			tile.get_node("TextureButton").visible = true
			if is_instance_valid(tile.tenant):
				tile.get_node("TextureButton/Polygon2D").color = "#ff7700"


func _handle_board_tile_button_clicked(tile):
	var currentPlayer = Data.players[0]
	var opposingPlayer = Data.players[1]
	
	#print("Moving " + PIECE.color +" "+ PIECE.type_of_piece + " to " + str(coords))
	
	if MOVING_PIECE.type_of_piece == "King" and MOVING_PIECE.first_move:
		boardTiles[MOVING_PIECE.coords.x][MOVING_PIECE.coords.y].queue_free()
	
	#Moving a newly deployed piece onto the board
	if MOVING_PIECE.coords == null:
		
		#currentPlayer.points -= GAME_BOARD.pieceValues[PIECE.type_of_piece]
		update_player_points.emit(-Data.pieceValues[MOVING_PIECE.type_of_piece])
		currentPlayer.pieces.push_back(MOVING_PIECE)
		updateBuyAvailable(false) 
	else:
		boardTiles[MOVING_PIECE.coords.x][MOVING_PIECE.coords.y].tenant = null
		updateMoveAvailable(false)
		MOVING_PIECE.first_move = false
	
	MOVING_PIECE.coords = tile.coords
	MOVING_PIECE.z_index = tile.z_index + 1
	MOVING_PIECE.moveTo(tile.position)
	
	#If there is a piece
	if is_instance_valid(tile.tenant):
		if tile.tenant.type_of_piece == "King":
			#current player wins
			game_over(MOVING_PIECE.color)
		else:
			#currentPlayer.points += pieceValues[tenant.type_of_piece]
			update_player_points.emit(Data.pieceValues[tile.tenant.type_of_piece])
			opposingPlayer.pieces.erase(tile.tenant)
			tile.tenant.queue_free()
		
	tile.tenant = MOVING_PIECE
	
	resetMoveTiles()
	MOVING_PIECE = null
