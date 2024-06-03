extends Node2D

const blackPieces = preload("res://sprites/black_marble_sprites.tscn")
const whitePieces = preload("res://sprites/white_marble_sprites.tscn")

var color
var type_of_piece
var coords

func createPiece(clr, type):
	self.color = clr
	self.type_of_piece = type
	var spriteSet
	if color == "White":
		spriteSet = whitePieces.instantiate()
	else: 
		spriteSet = blackPieces.instantiate()
	self.add_child(spriteSet)
	
	match type:
		"King":
			print("creating King")
			spriteSet.frame = 8
		"Queen":
			print("creating Queen")
			spriteSet.frame = 10
		"Rook":
			print("creating Rook")
			spriteSet.frame = 11
		"Knight":
			print("creating Knight")
			spriteSet.frame = 4 if clr == "White" else 7
		"Bishop":
			print("creating Bishop")
			spriteSet.frame = 0 if clr == "White" else 3
		"Pawn":
			print("creating Pawn")
			spriteSet.frame = 12
		var wild_card:
			print(wild_card)


func _on_chesspiece_clicked():
	print("Clicked on " + str(color) + " " + str(type_of_piece))
	print("Coords: " + str(coords))
	var GAME_BOARD = find_parent("GameBoard")
	
	GAME_BOARD.resetMoveTiles()
	
	if GAME_BOARD.creatingPiece:
		GAME_BOARD.MOVING_PIECE.queue_free()
		GAME_BOARD.MOVING_PIECE = null
		GAME_BOARD.creatingPiece = false
	
	if GAME_BOARD.MOVING_PIECE != self:
		GAME_BOARD.MOVING_PIECE = self
		
		for x in range(3):
			for y in range(3):
				
				# Targeting piece
				if x == 1 and y == 1: continue
				# Target is off board on left or right
				if coords.x + (x-1) < 0 or coords.x + (x-1) > 7: continue
				# Target is off board on top or bottom
				if coords.y + (y-1) < 0 or coords.y + (y-1) > 2: continue
				# Check for corners (missing values in array)
				if GAME_BOARD.boardTiles[coords.x+(x-1)][coords.y+(y-1)] == null: continue
				# Check for other pieces
				if is_instance_valid(GAME_BOARD.boardTiles[coords.x+(x-1)][coords.y+(y-1)].tenant): 
					print("Another piece was found")
					continue
					
				
				GAME_BOARD.boardTiles[coords.x+(x-1)][coords.y+(y-1)].get_node("TextureButton").visible = true
	else:
		GAME_BOARD.MOVING_PIECE = null

func moveTo(pos):
	var tween = create_tween()
	tween.tween_property(self, "position", pos, .25)
