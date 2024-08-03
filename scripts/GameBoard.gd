extends Node2D

const BoardTile = preload("res://board_tile.tscn")
const ChessPiece = preload("res://chess_piece.tscn")

var boardTiles = []
var MOVING_PIECE
var NEW_PIECE = null
var playerTurn = ["White", "Black"]
var moveAvailable = true
var buyAvailable = true
const pieceValues = {
	"Pawn": 1,
	"Bishop": 2,
	"Knight": 3,
	"Rook": 5,
	"Queen": 9,
}
var player = {
	"White": {
		"pieces": [],
		"points": 5,
	},
	"Black": {
		"pieces": [],
		"points": 5,
	},
}

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
			newBoardTile.z_index = 10 + (y * 10)
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
				newChessPiece.is_moveable = true
				add_child(newChessPiece)
				player[color].pieces.push_back(newChessPiece)
				newBoardTile.tenant = newChessPiece
		
		boardTiles.push_back(newRow)
		updatePoints()

func resetMoveTiles():
	for x in boardTiles:
		for tile in x:
			if tile != null:
				tile.get_node("TextureButton").visible = false
				tile.get_node("TextureButton/Polygon2D").color = "#00ff00"

func isACorner(x, y):
	return (x == 0 or x == 7) and (y == 0 or y == 2)

func _on_buy_piece_button_up(piece_name):
	if not buyAvailable: return
	
	var emptyTileFound = false
	var spawnColumns = [1, 2] if playerTurn[0] == "White" else [5, 6]
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
		newChessPiece.createPiece(playerTurn[0], piece_name)
		newChessPiece.position = Vector2(32 * 7, -64)
		add_child(newChessPiece)
		NEW_PIECE = newChessPiece
		MOVING_PIECE = newChessPiece
	else:
		print("No tiles available for new piece")

func updatePoints():
	$"../CanvasLayer/MarginContainer/HBoxContainer2/WhitePoints/Value".text = "[center]" + str(player.White.points) + "[/center]"
	$"../CanvasLayer/MarginContainer/HBoxContainer2/BlackPoints/Value".text = "[center]" + str(player.Black.points) + "[/center]"

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
			
			if isValidTile.call(coords + Vector2(xDirection, 1)) and is_instance_valid(boardTiles[coords.x + xDirection][coords.y + 1].tenant) and boardTiles[coords.x + xDirection][coords.y + 1].tenant.color != playerTurn[0]:
				tilesArray.push_back(boardTiles[coords.x + xDirection][coords.y + 1])
			
			if isValidTile.call(coords + Vector2(xDirection, -1)) and is_instance_valid(boardTiles[coords.x + xDirection][coords.y - 1].tenant) and boardTiles[coords.x + xDirection][coords.y - 1].tenant.color != playerTurn[0]:
				tilesArray.push_back(boardTiles[coords.x + xDirection][coords.y - 1])
			
			if isValidTile.call(coords + Vector2(xDirection, 0)) and not is_instance_valid(boardTiles[coords.x + xDirection][coords.y].tenant): 
				tilesArray.push_back(boardTiles[coords.x + xDirection][coords.y])
				if CHESS_PIECE.first_move and isValidTile.call(coords + Vector2(xDirection * 2, 0)) and not is_instance_valid(boardTiles[coords.x + (xDirection * 2)][coords.y].tenant):
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

func _on_end_turn_button_button_up():
	resetMoveTiles()
	if is_instance_valid(MOVING_PIECE) and MOVING_PIECE == NEW_PIECE:
		NEW_PIECE = null
		MOVING_PIECE.queue_free()
		MOVING_PIECE = null
	if is_instance_valid(NEW_PIECE):
		NEW_PIECE.is_moveable = true
		NEW_PIECE = null
	
	#Initialize new turn
	playerTurn.reverse()
	player[playerTurn[0]].points += 1
	moveAvailable = true
	buyAvailable = true
	updatePoints()
	
	for piece in player.White.pieces:
		var TEXTURE_BUTTON = piece.get_node("TextureButton")
		TEXTURE_BUTTON.disabled = playerTurn[0] == "Black"
		TEXTURE_BUTTON.set_mouse_filter(2 if playerTurn[0] == "Black" else 0)
	
	for piece in player.Black.pieces:
		var TEXTURE_BUTTON = piece.get_node("TextureButton")
		TEXTURE_BUTTON.disabled = playerTurn[0] == "White"
		TEXTURE_BUTTON.set_mouse_filter(2 if playerTurn[0] == "White" else 0)
	updateBuyButtons()

func updateBuyButtons():
	for button in $"../CanvasLayer/MarginContainer/HBoxContainer2/HBoxContainer".get_children():
		button.isAvailable()

func game_over():
	$"../CanvasLayer".visible = false
	var gameOverScreen = load("res://game_over.tscn").instantiate()
	gameOverScreen.get_node("WinnerMessage").text = "[center]" + str(playerTurn[0]).to_upper() + " IS THE WINNER!"
	get_parent().add_child(gameOverScreen)
