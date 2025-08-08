extends PanelContainer

signal create_new_game
signal join_created_game(code)

const STEP_ONE = preload("res://scenes/UI-elements/step_1.tscn")
const SHOW_CODE =  preload("res://scenes/room_code_display.tscn")
const INPUT_CODE = preload("res://scenes/input_join_code.tscn")


func _ready():
	present_step_one()


func present_step_one():
	clear_children()
	var next_step = STEP_ONE.instantiate()
	next_step.connect("step_one_input", _on_step_1_step_one_input)
	add_child(next_step)


func _on_step_1_step_one_input(choice):
	match choice:
		"CREATE":
			create_new_game.emit()
		"JOIN":
			clear_children()
			var request_code_screen = INPUT_CODE.instantiate()
			request_code_screen.connect("join_room_with_code", _submit_join_code)
			request_code_screen.connect("go_back_to_step1", present_step_one)
			add_child(request_code_screen)
		_:
			print("Unknown input received from Step 1")

func _submit_join_code(code):
	# TODO: handle wrong codes
	join_created_game.emit(code)


func present_room_code(code):
	clear_children()
	
	var show_code_screen = SHOW_CODE.instantiate()
	show_code_screen.connect("code_confirmed", _close_multiplayer_popup)
	show_code_screen.update_code(code)
	add_child(show_code_screen)


func clear_children():
	for child in get_children():
		remove_child(child)
	

func _close_multiplayer_popup():
	self.visible = false
