extends Node2D

const BoardTile = preload("res://board_tile.tscn")
const ChessPiece = preload("res://chess_piece.tscn")

var boardTiles = []
var MOVING_PIECE
var creatingPiece = false

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
	resetMoveTiles()
	
	for tile in boardTiles[1]:
		if not is_instance_valid(tile.tenant):
			tile.get_node("TextureButton").visible = true
			emptyTileFound = true
	for tile in boardTiles[2]:
		if not is_instance_valid(tile.tenant):
			tile.get_node("TextureButton").visible = true
			emptyTileFound = true
	
	if emptyTileFound:
		print("Buying " + piece_name)
		# CREATE PIECE
		var newChessPiece = ChessPiece.instantiate()
		#var color = "White"
		newChessPiece.createPiece("White", piece_name)
		add_child(newChessPiece)
		creatingPiece = true
		MOVING_PIECE = newChessPiece
	else:
		print("No tiles available for move")
	
	#newChessPiece.position = newBoardTile.position
	#newChessPiece.coords = Vector2(x, y)
	#newBoardTile.tenant = newChessPiece
