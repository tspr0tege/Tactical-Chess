extends Node2D

const BoardTile = preload("res://scenes/board_tile.tscn")
const ChessPiece = preload("res://scenes/chess_piece.tscn")
@onready var MoveAvailableControl = $"../CanvasLayer/RightPanel/MarginContainer/TurnControls/AvailableActions/MoveAvailable"
@onready var BuyAvailableControl = $"../CanvasLayer/RightPanel/MarginContainer/TurnControls/AvailableActions/BuyAvailable"
@onready var RightPanelUI = $"../CanvasLayer/RightPanel"
@onready var BottomPanelUI = $"../CanvasLayer/MarginContainer"

var boardTiles = []
var MOVING_PIECE = null
var moveAvailable = true
var buyAvailable = true
const pieceValues = {
	"Pawn": 1,
	"Bishop": 2,
	"Knight": 3,
	"Rook": 5,
	"Queen": 9,
}
var player = [
	{
		"color": "White",
		"pieces": [],
		"points": 1,
		"spawn_columns": [1, 2],
		"button_theme": "res://themes/white_player_turn_theme.tres",
	},
	{
		"color": "Black",
		"pieces": [],
		"points": 0,
		"spawn_columns": [5, 6],
		"button_theme": "res://themes/black_player_turn_theme.tres",
	},
]

func _ready():
	player[0].points_display = get_node("../CanvasLayer/MarginContainer/HBoxContainer2/WhitePoints/Value")
	player[1].points_display = get_node("../CanvasLayer/MarginContainer/HBoxContainer2/BlackPoints/Value")
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
				player[x if x == 0 else 1].pieces.push_back(newChessPiece)
				newBoardTile.tenant = newChessPiece
		
		boardTiles.push_back(newRow)
		#initializeTurn()

func resetMoveTiles():
	for x in boardTiles:
		for tile in x:
			if tile != null:
				tile.get_node("TextureButton").visible = false
				tile.get_node("TextureButton/Polygon2D").color = "#00ff00"

func updatePoints(value):
	player[0].points += value
	player[0].points_display.text = "[center]" + str(player[0].points) + "[/center]"
	#player[1].points_display.text = "[center]" + str(player[1].points) + "[/center]"
	for button in $"../CanvasLayer/MarginContainer/HBoxContainer2/HBoxContainer".get_children():
		button.isAvailable()

func clearBuyBox():
	if is_instance_valid(MOVING_PIECE) and MOVING_PIECE.coords == null:
		MOVING_PIECE.queue_free()
		MOVING_PIECE = null

func updateBuyAvailable(bool):
	buyAvailable = bool
	BuyAvailableControl.modulate = "#33ff33" if bool else "#cc4466"
	BuyAvailableControl.tooltip_text = "New piece available" if bool else "New piece not available"
	
func updateMoveAvailable(bool):
	moveAvailable = bool
	MoveAvailableControl.modulate = "#33ff33" if bool else "#cc4466"
	MoveAvailableControl.tooltip_text = "Move available" if bool else "Move not available"

func sacrificePawn():
	resetMoveTiles()
	updateMoveAvailable(false)
	updatePoints(2)
	player[0].pieces.erase(MOVING_PIECE)
	MOVING_PIECE.queue_free()

func initializeTurn():
	RightPanelUI.theme = load(player[0].button_theme)
	BottomPanelUI.theme = load(player[0].button_theme)
	updateMoveAvailable(true)
	updateBuyAvailable(true)
	updatePoints(1)
	
	for piece in player[0].pieces:
		var TEXTURE_BUTTON = piece.get_node("TextureButton")
		TEXTURE_BUTTON.disabled = false
		TEXTURE_BUTTON.set_mouse_filter(0)
	
	for piece in player[1].pieces:
		var TEXTURE_BUTTON = piece.get_node("TextureButton")
		TEXTURE_BUTTON.disabled = true
		TEXTURE_BUTTON.set_mouse_filter(2)

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
					if x == 1 and y == 1: continue
					if not isValidTile.call(coords + Vector2(x-1, y-1)): continue
					tilesArray.push_back(boardTiles[coords.x+(x-1)][coords.y+(y-1)])
		"Rook":
			getCrossMovementTiles.call()
		"Pawn":
			var xDirection = 1 if CHESS_PIECE.color == "White" else -1
			var diagonals = [coords + Vector2(xDirection, 1), coords + Vector2(xDirection, -1)]
			
			var isAttackable = func(targetCoords):
				var tile = boardTiles[targetCoords.x][targetCoords.y]
				if not is_instance_valid(tile.tenant): return false
				if tile.tenant.color == player[0].color: return false
				return true
			
			#Check diagonal attacks
			for diagonal in diagonals:
				if isValidTile.call(diagonal) and isAttackable.call(diagonal):
					tilesArray.push_back(boardTiles[diagonal.x][diagonal.y])
			
			#Check forward movement
			if isValidTile.call(coords + Vector2(xDirection, 0)) and not is_instance_valid(boardTiles[coords.x + xDirection][coords.y].tenant): 
				tilesArray.push_back(boardTiles[coords.x + xDirection][coords.y])
				#Check second square on first move
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
	clearBuyBox()
	
	if player[0].points >= 20:
		game_over()
		return
	
	player[0].pieces[-1].is_moveable = true
		
	#Initialize new turn
	player.reverse()
	initializeTurn()

func _on_buy_piece_button_up(piece_name):
	resetMoveTiles()
	clearBuyBox()
	
	if not buyAvailable: return
	
	var emptyTiles = []
	
	for tile in boardTiles[player[0].spawn_columns[0]]:
		if not is_instance_valid(tile.tenant):
			emptyTiles.push_back(tile.get_node("TextureButton"))
	for tile in boardTiles[player[0].spawn_columns[1]]:
		if not is_instance_valid(tile.tenant):
			emptyTiles.push_back(tile.get_node("TextureButton"))
	
	if emptyTiles.size() > 0:
		print("Buying " + piece_name)
		for tile in emptyTiles: tile.visible = true
		# CREATE PIECE
		var newChessPiece = ChessPiece.instantiate()
		newChessPiece.createPiece(player[0].color, piece_name)
		newChessPiece.position = Vector2(32 * 7, -64)
		add_child(newChessPiece)
		MOVING_PIECE = newChessPiece
	else:
		print("No tiles available for new piece")

func game_over():
	$"../CanvasLayer".visible = false
	var gameOverScreen = load("res://game_over.tscn").instantiate()
	gameOverScreen.get_node("WinnerMessage").text = "[center]" + str(player[0].color).to_upper() + " IS THE WINNER!"
	get_parent().add_child(gameOverScreen)
