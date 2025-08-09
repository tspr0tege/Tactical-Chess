extends Node

const pieceValues = {
	"Pawn": 1,
	"Bishop": 2,
	"Knight": 3,
	"Rook": 5,
	"Queen": 9,
	"King": 0
}

var is_multiplayer_game = false
var local_player_color = null
var multiplayer_id = null

var player_turn = "White"

