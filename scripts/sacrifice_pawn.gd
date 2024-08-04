extends Panel

@onready var GAME_BOARD = find_parent("Main").get_node("GameBoard")

func _on_sacrifice_button_down():
	if GAME_BOARD == null:
		print("Game Board is not loaded")
		return
	
	GAME_BOARD.sacrificePawn()
	self.queue_free()

func _on_cancel_button_down():
	self.queue_free()
