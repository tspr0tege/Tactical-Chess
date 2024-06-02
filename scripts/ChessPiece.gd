extends Node2D

const blackPieces = preload("res://sprites/black_marble_sprites.tscn")
const whitePieces = preload("res://sprites/white_marble_sprites.tscn")

var color
var type_of_piece
var coords = []

func createPiece(color, type):
	self.color = color
	self.type_of_piece = type
	var spriteSet
	if color == "White":
		spriteSet = whitePieces.instantiate()
	else: 
		spriteSet = blackPieces.instantiate()
	self.add_child(spriteSet)
	spriteSet.frame = 8


func _on_chesspiece_clicked():
	print("Clicked on " + str(color) + " " + str(type_of_piece))
	print("Coords: " + str(coords))
	var GAME_BOARD = find_parent("GameBoard")
	
	for x in range(3):
		for y in range(3):
			
			# Targeting piece
			if x == 1 and y == 1: continue
			# Target is off left or right
			if coords[0] + (x-1) < 0 or coords[0] + (x-1) > 7: continue
			# Target is off top or bottom
			if coords[1] + (y-1) < 0 or coords[1] + (y-1) > 2: continue
			# Check for corners (missing values in array)
			if GAME_BOARD.boardTiles[coords[0]+(x-1)][coords[1]+(y-1)] == null: continue
			
			GAME_BOARD.boardTiles[coords[0]+(x-1)][coords[1]+(y-1)].get_node("TextureButton").visible = true
	
