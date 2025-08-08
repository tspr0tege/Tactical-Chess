extends PanelContainer

signal code_confirmed

@export var CODE_DISPLAY_LABEL : Label

func _on_okay_pressed():
	code_confirmed.emit()

func update_code(code):
	CODE_DISPLAY_LABEL.text = str(code)
