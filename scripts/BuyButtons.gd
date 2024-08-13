extends Button

@onready var MAIN = find_parent("Main")
@onready var piece = self.name.substr(0, self.name.length() - 6)
@onready var cost = MAIN.pieceValues[piece]

func _ready():
	isAvailable()
	self.tooltip_text = str(piece) + ": " + str(cost) + (" point" if cost == 1 else " points")

func isAvailable():
	var availablePoints = MAIN.player[0].points
	if availablePoints >= cost:
		self.disabled = false
	else:
		self.disabled = true
