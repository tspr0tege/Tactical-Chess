extends Node2D

const BoardTile = preload("res://board_tile.tscn")

var boardTiles = []

func _ready():
	for x in range(8):
		var newRow = []
		for y in range(3):
			if (isACorner(x, y)):
				continue
			
			var newBoardTile = BoardTile.instantiate()
			newBoardTile.position.x = x * 64
			newBoardTile.position.y = y * 64
			
			if (x + y) % 2 == 0:
				newBoardTile.get_node("Sprite2D").frame = randi_range(4, 7)
			else:
				newBoardTile.get_node("Sprite2D").frame = randi_range(0, 3)
			
			newBoardTile.get_node("Sprite2D").flip_h = randi() % 2 == 0
			
			add_child(newBoardTile)
			newRow.push_back(newBoardTile)
		
		boardTiles.push_back(newRow)

func isACorner(x, y):
	return (x == 0 or x == 7) and (y == 0 or y == 2)
