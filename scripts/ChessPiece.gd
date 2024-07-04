extends Node2D

const blackPieces = preload("res://sprites/black_marble_sprites.tscn")
const whitePieces = preload("res://sprites/white_marble_sprites.tscn")


@onready var GAME_BOARD = find_parent("GameBoard")
var first_move = true
var type_of_piece
var color
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
			print("ERROR: unable to match type_of_piece in createPiece. Received: " + str(wild_card))

func _on_chesspiece_clicked():
	#print("Clicked on " + str(color) + " " + str(type_of_piece))
	#print("Coords: " + str(coords))
	GAME_BOARD.resetMoveTiles()
	
	if GAME_BOARD.creatingPiece:
		GAME_BOARD.MOVING_PIECE.queue_free()
		GAME_BOARD.MOVING_PIECE = null
		GAME_BOARD.creatingPiece = false
	
	if GAME_BOARD.MOVING_PIECE != self:
		GAME_BOARD.MOVING_PIECE = self
		
		var movementTiles = GAME_BOARD.getMovementTiles(self)
		for tile in movementTiles:
			tile.get_node("TextureButton").visible = true
		
	else:
		GAME_BOARD.MOVING_PIECE = null

func moveTo(pos):
	var tween = create_tween()
	tween.tween_property(self, "position", pos, .25)

