extends Node2D

const blackPieces = preload("res://sprites/black_marble_sprites.tscn")
const whitePieces = preload("res://sprites/white_marble_sprites.tscn")


@onready var GAME_BOARD = find_parent("GameBoard")
var first_move = true
var type_of_piece
var coords
var color

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
		
		match type_of_piece:
			"King":
				generateKingMovementTiles()
			"Rook":
				generateCrossMovementTiles()
			"Pawn":
				generatePawnMovementTiles()
			"Knight":
				generateKnightMovementTiles()
			"Bishop":
				generateDiagonalMovementTiles()
			"Queen":
				generateCrossMovementTiles()
				generateDiagonalMovementTiles()
		
	else:
		GAME_BOARD.MOVING_PIECE = null

func moveTo(pos):
	var tween = create_tween()
	tween.tween_property(self, "position", pos, .25)

func isValidTile(coords):
	# Target is off board on left or right
	if coords.x < 0 or coords.x > 7: return false
	# Target is off board on top or bottom
	if coords.y < 0 or coords.y > 2: return false
	# Check for corners (missing values in array)
	if GAME_BOARD.boardTiles[coords.x][coords.y] == null: return false
	# Check for same team piece
	if is_instance_valid(GAME_BOARD.boardTiles[coords.x][coords.y].tenant) and GAME_BOARD.boardTiles[coords.x][coords.y].tenant.color == color: return false
	
	return true

func generateKingMovementTiles():
	for x in range(3):
		for y in range(3):			
			# Targeting piece
			if x == 1 and y == 1: continue
			
			if not isValidTile(coords + Vector2(x-1, y-1)): continue
			
			# Check for attackable pieces
			
			GAME_BOARD.boardTiles[coords.x+(x-1)][coords.y+(y-1)].get_node("TextureButton").visible = true

func generateCrossMovementTiles():
	# right
	for x in range(8 - coords.x):
		if x == 0: continue
		if isValidTile(coords + Vector2(x, 0)):
			GAME_BOARD.boardTiles[coords.x + x][coords.y].get_node("TextureButton").visible = true
		else: break
		
	# down
	for x in range(3 - coords.y):
		if x == 0: continue
		if isValidTile(coords + Vector2(0, x)):
			GAME_BOARD.boardTiles[coords.x][coords.y + x].get_node("TextureButton").visible = true
		else: break
		
	# left
	for x in range(coords.x + 1):
		if x == 0: continue
		if isValidTile(coords + Vector2(-x, 0)):
			GAME_BOARD.boardTiles[coords.x - x][coords.y].get_node("TextureButton").visible = true
		else: break
		
	# up
	for x in range(coords.y + 1):
		if x == 0: continue
		if isValidTile(coords + Vector2(0, -x)):
			GAME_BOARD.boardTiles[coords.x][coords.y - x].get_node("TextureButton").visible = true
		else: break
	
func generateDiagonalMovementTiles():
	# +/+ SouthEast
	for x in range(3 - coords.y):
		if x == 0: continue
		if isValidTile(coords + Vector2(x, x)):
			GAME_BOARD.boardTiles[coords.x + x][coords.y + x].get_node("TextureButton").visible = true
		else: break
		
	# +/- NorthEast
	for x in range(coords.y + 1):
		if x == 0: continue
		if isValidTile(coords + Vector2(x, -x)):
			GAME_BOARD.boardTiles[coords.x + x][coords.y - x].get_node("TextureButton").visible = true
		else: break
		
	# -/- NorthWest
	for x in range(coords.y + 1):
		if x == 0: continue
		if isValidTile(coords + Vector2(-x, -x)):
			GAME_BOARD.boardTiles[coords.x - x][coords.y - x].get_node("TextureButton").visible = true
		else: break
		
	# -/+ SouthWest
	for x in range(3 - coords.y):
		if x == 0: continue
		if isValidTile(coords + Vector2(-x, x)):
			GAME_BOARD.boardTiles[coords.x - x][coords.y + x].get_node("TextureButton").visible = true
		else: break
	
func generateKnightMovementTiles():
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
		if isValidTile(targetCoords):
			GAME_BOARD.boardTiles[targetCoords.x][targetCoords.y].get_node("TextureButton").visible = true
	
func generatePawnMovementTiles():
	var xDirection = 1 if color == "White" else -1
	# Check back row for piece sacrifice (get 2 points)
	
	
	if isValidTile(coords + Vector2(xDirection, 0)):
		GAME_BOARD.boardTiles[coords.x + xDirection][coords.y].get_node("TextureButton").visible = true
		if first_move and isValidTile(coords + Vector2(xDirection * 2, 0)):
			GAME_BOARD.boardTiles[coords.x + (xDirection * 2)][coords.y].get_node("TextureButton").visible = true
	# Check diagonals for attack
