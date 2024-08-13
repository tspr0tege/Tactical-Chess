extends Node2D

@onready var SCENE_LOADER = find_parent("Scene Loader")
@onready var NE_CONTAINER = %NEContainer
@onready var BOTTOM_PANEL = %BottomPanel
@onready var BUY_BUTTONS_CONTAINER = %BuyButtonsContainer
#@onready var WHITE_POINTS = %WhitePoints.get_node("Display/CenterContainer/Value")
#@onready var BLACK_POINTS = %BlackPoints.get_node("Display/CenterContainer/Value")

const pieceValues = {
	"Pawn": 1,
	"Bishop": 2,
	"Knight": 3,
	"Rook": 5,
	"Queen": 9,
}
var player = [
	{
		"color": "White",
		"pieces": [],
		"points": 1,
		"spawn_columns": [1, 2],
		"button_theme": "res://themes/white_player_turn_theme.tres",
	},
	{
		"color": "Black",
		"pieces": [],
		"points": 0,
		"spawn_columns": [5, 6],
		"button_theme": "res://themes/black_player_turn_theme.tres",
	},
]

func _ready():
	player[0].points_display = %WhitePoints.get_node("Display/CenterContainer/Value")
	player[1].points_display = %BlackPoints.get_node("Display/CenterContainer/Value")

func _on_restart_button_down():
	if SCENE_LOADER == null:
		print("No Scene Loader is present")
		return 
	
	print("Starting new game!")
	SCENE_LOADER.load_new_game()


func _on_quit_button_down():
	if SCENE_LOADER == null:
		print("No Scene Loader is present")
		return 
	
	print("Quitting")
	SCENE_LOADER.load_main_menu()


func _on_sub_viewport_container_item_rect_changed():
	pass # Replace with function body.
