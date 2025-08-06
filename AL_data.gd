extends Node


const pieceValues = {
	"Pawn": 1,
	"Bishop": 2,
	"Knight": 3,
	"Rook": 5,
	"Queen": 9,
}


var players = [
	{
		"color": "White",
		"pieces": [],
		"points": 1,
		"spawn_columns": [1, 2],
		"button_theme": "res://themes/white_player_turn_theme.tres",
		#"update_points": _update_white_points
	},
	{
		"color": "Black",
		"pieces": [],
		"points": 0,
		"spawn_columns": [5, 6],
		"button_theme": "res://themes/black_player_turn_theme.tres",
		#"update_points": _update_black_points
	},
]
