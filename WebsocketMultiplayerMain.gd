extends Main

@export var MULTIPLAYER_POP_UP : Container
@export var END_TURN_BUTTON : Button
@export var ID_LABEL : Label

var tls_options: TLSOptions = null

var socket := WebSocketPeer.new()
var last_state := WebSocketPeer.STATE_CLOSED
var next_action : Dictionary = {}
var remote_opponent_id = null

signal connected_to_server()
signal connection_closed()
signal message_received(message: Variant)

var pawn_sacrifice_template = {
	"origin": Data.multiplayer_id,
	"type": "game_input",
	"input": {
		"opponent_id": remote_opponent_id,
		"action": "SACRIFICE_PAWN",
		"coords": "Object/Dictionary"
	},
}

var create_piece_template = {
	"origin": Data.multiplayer_id,
	"type": "game_input",
	"input": {
		"opponent_id": remote_opponent_id,
		"action": "CREATE",
		"coords": "target_coords Object/Dictionary",
		"piece": "type_of_piece",
		"color": "creator player's color"
	},
}

func connect_to_url(url: String) -> int:
	#socket.supported_protocols = supported_protocols
	#socket.handshake_headers = handshake_headers

	var err := socket.connect_to_url(url, tls_options)
	if err != OK:
		return err

	last_state = socket.get_ready_state()
	return OK


func close(code: int = 1000, reason: String = "") -> void:
	socket.close(code, reason)
	last_state = socket.get_ready_state()


func clear() -> void:
	socket = WebSocketPeer.new()
	last_state = socket.get_ready_state()


func poll() -> void:
	if socket.get_ready_state() != socket.STATE_CLOSED:
		socket.poll()

	var state := socket.get_ready_state()

	if last_state != state:
		last_state = state
		if state == socket.STATE_OPEN:
			print("Connected to server")
			connected_to_server.emit()
		elif state == socket.STATE_CLOSED:
			print("Socket Closed")
			connection_closed.emit()
	
	while socket.get_ready_state() == socket.STATE_OPEN and socket.get_available_packet_count():
		print("Message received")
		var received := socket.get_packet()
		var packet_from_utf8 = received.get_string_from_utf8()
		var data = JSON.parse_string(packet_from_utf8)
		print(data)
		message_received.emit(data)
		
		if Data.multiplayer_id == null and data.has("id"):
			Data.multiplayer_id = data.id
		
		if "error" in data:
			print("ERROR received from server: " + str(data.error))
		
		if !next_action.is_empty():
			if next_action.id == null: next_action.id = Data.multiplayer_id
			socket.put_packet(JSON.stringify(next_action).to_utf8_buffer())
			next_action.clear()
				
		if data.has("type"):
			match data.type:
				
				"new_offer":
					print("New offer created and room code received")
					Data.local_player_color = "White"
					MULTIPLAYER_POP_UP.present_room_code(data.room_code)
					#data.room_code
					
				"new_opponent":
					print("Connected to new remote opponent")
					remote_opponent_id = data.opponent_id
					if data.has("color_assigned"): 
						print("New Color assigned: %s" % data.color_assigned)
						Data.local_player_color = data.color_assigned
					MULTIPLAYER_POP_UP._close_multiplayer_popup()
					initialize_turn()
					
				"game_input":
					print("Processing input from remote")
					handle_remote_input(data)
					
				_:
					print("data dictionary has type: " + str(data.type))


func _process(_delta: float) -> void:
	poll()


func move_piece(tile, piece): #piece will have from coords, tile will have to coords
	var move_output = {
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": {
			"opponent_id": remote_opponent_id,
			"action": "MOVE",
			"from_coords": {"x": piece.coords.x, "y": piece.coords.y},
			"to_coords": {"x": tile.coords.x, "y": tile.coords.y},
			"piece": piece.type_of_piece #this will be for validation
		},
	}
	print(socket.send_text(JSON.stringify(move_output)))
	execute_move(tile, piece)


func execute_move(tile, piece):
	if piece.type_of_piece == "King" and piece.first_move:
		GAME_BOARD.boardTiles[piece.coords.x][piece.coords.y].queue_free()
	else:
		GAME_BOARD.boardTiles[piece.coords.x][piece.coords.y].tenant = null
	
	GAME_BOARD.moveAvailable = false
	piece.first_move = false	
	
	#If there is a piece - capture it
	if is_instance_valid(tile.tenant):
		if tile.tenant.type_of_piece == "King":
			print(str(piece.color) + " Wins!")
		else:
			update_player_points(Data.pieceValues[tile.tenant.type_of_piece])
			players[tile.tenant.color].pieces.erase(tile.tenant)
			tile.tenant.queue_free()
	
	piece.moveTo(tile)
	GAME_BOARD.PENDING_ACTION = null


func sacrifice_pawn(piece):
	var sacrifice_pawn_output = {
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": {
			"opponent_id": remote_opponent_id,
			"action": "SACRIFICE_PAWN",
			"coords": {"x": piece.coords.x, "y": piece.coords.y}
		},
	}
	print(socket.send_text(JSON.stringify(sacrifice_pawn_output)))
	execute_sacrifice_pawn(piece)


func execute_sacrifice_pawn(piece):
	GAME_BOARD.resetMoveTiles()
	GAME_BOARD.moveAvailable = false
	update_player_points(2)
	players[Data.player_turn].pieces.erase(piece)
	piece.queue_free()
	SACRIFICE_PAWN_BUTTON.visible = false
	GAME_BOARD.PENDING_ACTION = null
	SACRIFICE_PAWN_BUTTON.disconnect("button_up", sacrifice_pawn)


func create_new_piece(tile, piece_name, color = Data.player_turn):
	var new_piece_output = {
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": {
			"opponent_id": remote_opponent_id,
			"action": "CREATE",
			"coords": {"x": tile.coords.x, "y": tile.coords.y},
			"piece": piece_name,
			"color": color
		},
	}
	print(socket.send_text(JSON.stringify(new_piece_output)))
	execute_create_new_piece(tile, piece_name, color)


func execute_create_new_piece(tile, piece_name, color):
	var player = players[color]
	var newChessPiece = ChessPiece.instantiate()
	newChessPiece.createPiece(color, piece_name)
	if piece_name != "King":
		update_player_points(-Data.pieceValues[piece_name])
	newChessPiece.connect("chesspiece_clicked", GAME_BOARD._handle_chesspiece_clicked)
	players[color].pieces.push_back(newChessPiece)
	newChessPiece.moveTo(tile, true)
	GAME_BOARD.add_child(newChessPiece)
	GAME_BOARD.buyAvailable = false
	for button in BUY_BUTTONS_CONTAINER.get_children():
		button.disabled = true
	GAME_BOARD.PENDING_ACTION = null


func _signal_end_turn():
	var request = {
		"origin": Data.multiplayer_id,
		"type": "game_input",
		"input": {
			"opponent_id": remote_opponent_id,
			"action": "END_TURN",
		}
	}
	print(socket.send_text(JSON.stringify(request)))
	_handle_end_turn()


func handle_remote_input(input: Dictionary) -> void:
	
	match input.action:
		
		"END_TURN":
			_handle_end_turn()
		
		"SACRIFICE_PAWN":
			#{"opponent_id": remote_opponent_id,
			#"action": "SACRIFICE_PAWN",
			#"coords": {"x": piece.coords.x, "y": piece.coords.y}}
			var target_piece = GAME_BOARD.boardTiles[input.coords.x][input.coords.y].tenant
			if !is_instance_valid(target_piece):
				push_error("Attempting to sacrifice a Pawn at %s, but no piece found" % input.coords)
			elif target_piece.type_of_piece != "Pawn":
				push_error("Attempting to sacrifice a Pawn at %s, but there is a %s there" % [input.coords, target_piece.type_of_piece])
			else:
				execute_sacrifice_pawn(target_piece)
		
		"CREATE":
			# {"opponent_id": remote_opponent_id,
			#"action": "CREATE",
			#"coords": {"x": tile.coords.x, "y": tile.coords.y},
			#"piece": piece_name,
			#"color": color	}
			var target_tile = GAME_BOARD.boardTiles[input.coords.x][input.coords.y]
			execute_create_new_piece(target_tile, input.piece, input.color)
		
		"MOVE":
			#{	"opponent_id": remote_opponent_id,
			#	"action": "MOVE",
			#	"from_coords": {"x": piece.coords.x, "y": piece.coords.y},
			#	"to_coords": {"x": tile.coords.x, "y": tile.coords.y},
			#	"piece": piece.type_of_piece #this will be for validation}
			var piece_to_move = GAME_BOARD.boardTiles[input.from_coords.x][input.from_coords.y].tenant
			var target_tile = GAME_BOARD.boardTiles[input.to_coords.x][input.to_coords.y]
			if !is_instance_valid(piece_to_move):
				push_error("Attempt to move %s at %s, but no piece found" % [input.piece, input.from_coords])
			else:
				execute_move(target_tile, piece_to_move)
		
		_:
			print("Remote input action not recognized")


func _on_create_room_pressed() -> void:
	next_action = {
		"id": Data.multiplayer_id,
		"type": "create_offer"
	}
	#Data.local_player_color = "White"
	connect_to_url("ws://127.0.0.1:9080")


func _on_join_code_submitted(code) -> void:
	next_action = {
		"id": Data.multiplayer_id,
		"type": "claim_offer",
		"room_code": code
	}
	connect_to_url("ws://127.0.0.1:9080")


func initialize_turn():
	NE_CONTAINER.theme = load(players[Data.player_turn].button_theme)
	BOTTOM_PANEL.theme = load(players[Data.player_turn].button_theme)
	ID_LABEL.text = str(Data.multiplayer_id)
	
	var all_pieces = get_tree().get_nodes_in_group("Chess Pieces")
	for piece in all_pieces:
		var TEXTURE_BUTTON = piece.get_node("TextureButton")
		TEXTURE_BUTTON.disabled = true
		TEXTURE_BUTTON.set_mouse_filter(2)
	
	if Data.local_player_color == Data.player_turn: # local player's turn
		NE_CONTAINER.visible = true
		GAME_BOARD.moveAvailable = true
		GAME_BOARD.buyAvailable = true
		for piece in players[Data.local_player_color].pieces:
			var TEXTURE_BUTTON = piece.get_node("TextureButton")		
			TEXTURE_BUTTON.disabled = false
			TEXTURE_BUTTON.set_mouse_filter(0)
		
	else: # not your turn
		NE_CONTAINER.visible = false
		GAME_BOARD.moveAvailable = false
		GAME_BOARD.buyAvailable = false

