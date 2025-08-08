class_name ChessPiece extends Node2D

const blackPieces = preload("./black_plastic_sprites.tscn")
const whitePieces = preload("./white_plastic_sprites.tscn")

signal chesspiece_clicked(piece)

var color
var type_of_piece
var coords
var first_move = true


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
			#print("creating King")
			spriteSet.frame = 8
		"Queen":
			#print("creating Queen")
			spriteSet.frame = 10
		"Rook":
			#print("creating Rook")
			spriteSet.frame = 11
		"Knight":
			#print("creating Knight")
			spriteSet.frame = 4 if clr == "White" else 7
		"Bishop":
			#print("creating Bishop")
			spriteSet.frame = 0 if clr == "White" else 3
		"Pawn":
			#print("creating Pawn")
			spriteSet.frame = 12
		var wild_card:
			print("ERROR: unable to match type_of_piece in createPiece. Received: " + str(wild_card))


func _on_chesspiece_clicked():
	chesspiece_clicked.emit(self)


func moveTo(tile, skip_tween := false):
	coords = tile.coords
	z_index = tile.z_index + 1
	tile.tenant = self
	if skip_tween:
		position = tile.position
	else:
		var tween = create_tween()
		tween.tween_property(self, "position", tile.position, .25)
