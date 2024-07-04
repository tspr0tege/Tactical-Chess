extends Node2D

const BoardTile = preload("res://board_tile.tscn")
const ChessPiece = preload("res://chess_piece.tscn")

var boardTiles = []
var MOVING_PIECE
var creatingPiece = false
var playerTurn = "White"

func _ready():
	for x in range(8):
		var newRow = []
		for y in range(3):
			if (isACorner(x, y)):
				newRow.push_back(null)
				continue
			
			var newBoardTile = BoardTile.instantiate()
			newBoardTile.position.x = x * 64
			newBoardTile.position.y = y * 64
			newBoardTile.coords = Vector2(x, y)
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
				add_child(newChessPiece)
				newBoardTile.tenant = newChessPiece
		
		boardTiles.push_back(newRow)
		
	#print(str(boardTiles))

func resetMoveTiles():
	for x in boardTiles:
		for tile in x:
			if tile != null:
				tile.get_node("TextureButton").visible = false

func isACorner(x, y):
	return (x == 0 or x == 7) and (y == 0 or y == 2)

func _on_buy_piece_button_up(piece_name):
	var emptyTileFound = false
	var spawnColumns = [1, 2] if playerTurn == "White" else [5, 6]
	resetMoveTiles()
	
	for tile in boardTiles[spawnColumns[0]]:
		if not is_instance_valid(tile.tenant):
			tile.get_node("TextureButton").visible = true
			emptyTileFound = true
	for tile in boardTiles[spawnColumns[1]]:
		if not is_instance_valid(tile.tenant):
			tile.get_node("TextureButton").visible = true
			emptyTileFound = true
	
	if emptyTileFound:
		print("Buying " + piece_name)
		# CREATE PIECE
		var newChessPiece = ChessPiece.instantiate()
		#var color = "White"
		newChessPiece.createPiece(playerTurn, piece_name)
		add_child(newChessPiece)
		creatingPiece = true
		MOVING_PIECE = newChessPiece
	else:
		print("No tiles available for new piece")

func getMovementTiles(CHESS_PIECE):
	var tilesArray = []
	var coords = CHESS_PIECE.coords
	
	var isValidTile = func(target_coords):
		# Target is off board on left or right
		if target_coords.x < 0 or target_coords.x > 7: return false
		# Target is off board on top or bottom
		if target_coords.y < 0 or target_coords.y > 2: return false
		
		var boardTile = boardTiles[target_coords.x][target_coords.y]
		# Check for corners (missing values in array)
		if boardTile == null: return false
		# Check for same team piece
		if is_instance_valid(boardTile.tenant) and boardTile.tenant.color == CHESS_PIECE.color: return false
		
		return true

	var getCrossMovementTiles = func():	
		# right
		for x in range(8 - coords.x):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(x, 0)):
				tilesArray.push_back(boardTiles[coords.x + x][coords.y])
			else: break
			
		# down
		for x in range(3 - coords.y):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(0, x)):
				tilesArray.push_back(boardTiles[coords.x][coords.y + x])
			else: break
			
		# left
		for x in range(coords.x + 1):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(-x, 0)):
				tilesArray.push_back(boardTiles[coords.x - x][coords.y])
			else: break
			
		# up
		for x in range(coords.y + 1):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(0, -x)):
				tilesArray.push_back(boardTiles[coords.x][coords.y - x])
			else: break

	var getDiagonalMovementTiles = func():		
		# +/+ SouthEast
		for x in range(3 - coords.y):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(x, x)):
				tilesArray.push_back(boardTiles[coords.x + x][coords.y + x])
			else: break
			
		# +/- NorthEast
		for x in range(coords.y + 1):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(x, -x)):
				tilesArray.push_back(boardTiles[coords.x + x][coords.y - x])
			else: break
			
		# -/- NorthWest
		for x in range(coords.y + 1):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(-x, -x)):
				tilesArray.push_back(boardTiles[coords.x - x][coords.y - x])
			else: break
			
		# -/+ SouthWest
		for x in range(3 - coords.y):
			if x == 0: continue
			if isValidTile.call(coords + Vector2(-x, x)):
				tilesArray.push_back(boardTiles[coords.x - x][coords.y + x])
			else: break

	match CHESS_PIECE.type_of_piece:
		"King":
			for x in range(3):
				for y in range(3):			
					# Targeting self
					if x == 1 and y == 1: continue
					
					if not isValidTile.call(coords + Vector2(x-1, y-1)): continue
					
					tilesArray.push_back(boardTiles[coords.x+(x-1)][coords.y+(y-1)])
		"Rook":
			getCrossMovementTiles.call()
		"Pawn":
			var xDirection = 1 if CHESS_PIECE.color == "White" else -1
			
			# TODO: Check back row for piece sacrifice (get 2 points)	
			
			if isValidTile.call(coords + Vector2(xDirection, 0)):
				tilesArray.push_back(boardTiles[coords.x + xDirection][coords.y])
				if CHESS_PIECE.first_move and isValidTile.call(coords + Vector2(xDirection * 2, 0)):
					tilesArray.push_back(boardTiles[coords.x + (xDirection * 2)][coords.y])
			
			# TODO: Check diagonals for attack
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
