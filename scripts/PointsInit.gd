extends RichTextLabel

@onready var GAME_BOARD = $"../../../../../GameBoard"
#@onready var piece = self.name.substr(0, self.name.length() - 6)

func _ready():
	var index = 0 if get_parent().name == "WhitePoints" else 1
	self.text = "[center]" + str(GAME_BOARD.player[index].points) + "[/center]"
