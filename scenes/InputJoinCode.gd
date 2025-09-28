extends PanelContainer

signal join_room_with_code(code)
signal go_back_to_step1

@export var CODE_INPUT_BOX : LineEdit
@export var SUBMIT_BUTTON : Button


func _on_submit_pressed():
	join_room_with_code.emit(CODE_INPUT_BOX.text)


func _on_code_input_box_text_changed(new_text):
	SUBMIT_BUTTON.disabled = new_text.length() != 4


func _on_cancel_pressed():
	go_back_to_step1.emit()


func _text_box_focus_entered():
	pass # Replace with function body.
