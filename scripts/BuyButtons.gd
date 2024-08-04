extends Button

@onready var GAME_BOARD = $"../../../../../GameBoard"
@onready var piece = self.name.substr(0, self.name.length() - 6)

func _ready():
	isAvailable()

func isAvailable():
	var availablePoints = GAME_BOARD.player[0].points
	if availablePoints >= GAME_BOARD.pieceValues[piece]:
		self.disabled = false
	else:
		self.disabled = true
