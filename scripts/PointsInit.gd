extends Label

@onready var MAIN = find_parent("Main")
#@onready var piece = self.name.substr(0, self.name.length() - 6)

func _ready():
	var index = 0 if get_parent().name == "WhitePoints" else 1
	self.text = str(MAIN.player[index].points)
