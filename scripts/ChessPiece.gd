extends Node2D

const blackPieces = preload("res://sprites/black_marble_sprites.tscn")
const whitePieces = preload("res://sprites/white_marble_sprites.tscn")

@onready var GAME_BOARD = find_parent("GameBoard")
var first_move = true
var type_of_piece
var is_moveable = false
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
	print("Clicked on " + str(color) + " " + str(type_of_piece))
	
	if not GAME_BOARD.player[0].color == color: return
	if not GAME_BOARD.moveAvailable: return
	if not is_moveable: return
	
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.clearBuyBox()
	
	if GAME_BOARD.MOVING_PIECE != self:
		GAME_BOARD.MOVING_PIECE = self
		
		var inBackRow = func():
			if color == "Black" and coords.x == 1: return true
			if color == "White" and coords.x == 6: return true
			return false
		# TODO: Check back row for piece sacrifice (get 2 points)
		if type_of_piece == "Pawn" and inBackRow.call():
			var sacrificePopup = load("res://sacrifice_pawn.tscn").instantiate()
			find_parent("Main").add_child(sacrificePopup)
		
		var movementTiles = GAME_BOARD.getMovementTiles(self)
		for tile in movementTiles:
			tile.get_node("TextureButton").visible = true
			if is_instance_valid(tile.tenant):
				tile.get_node("TextureButton/Polygon2D").color = "#ff7700"
		
	else:
		GAME_BOARD.MOVING_PIECE = null

func moveTo(pos):
	var tween = create_tween()
	tween.tween_property(self, "position", pos, .25)
