extends Main

@export var MULTIPLAYER_POP_UP : Container

var tls_options: TLSOptions = null

var socket := WebSocketPeer.new()
var last_state := WebSocketPeer.STATE_CLOSED
var next_action : Dictionary = {}
var remote_opponent_id = null

signal connected_to_server()
signal connection_closed()
signal message_received(message: Variant)

var end_turn_template = {
	"origin": "user_id",
	"type": "game_input",
	"action": "END_TURN",
}

var pawn_sacrifice_template = {
	"origin": "user_id",
	"type": "game_input",
	"action": "SACRIFICE_PAWN",
	"coords": "Object/Dictionary"
}

var create_piece_template = {
	"origin": "user_id",
	"type": "game_input",
	"action": "CREATE",
	"coords": "target_coords Object/Dictionary",
	"piece": "type_of_piece",
	"color": "creator player's color"
}

var move_template = {
	"origin": "user_id",
	"type": "game_input",
	"action": "MOVE",
	"from_coords": "piece.coords Object/Dictionary",
	"to_coords": "tile.coords Object/Dictionary",
	"piece": "type_of_piece" #this will be for validation
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


func _on_create_room_pressed() -> void:
	next_action = {
		"id": Data.multiplayer_id,
		"action": "create_offer"
	}
	#Data.local_player_color = "White"
	connect_to_url("ws://127.0.0.1:9080")


func _on_join_code_submitted(code) -> void:
	next_action = {
		"id": Data.multiplayer_id,
		"action": "claim_offer",
		"room_code": code
	}
	connect_to_url("ws://127.0.0.1:9080")


func _on_chat_container_send_message(message: String) -> void:
	print("Sending message: " + message)
	#var request = user_data
	#request.action = "message"
	#request.recipient = peer_client_id
	#request.content = message
	
	#print(socket.send_text(JSON.stringify(request)))


func handle_remote_input(input: Dictionary) -> void:
	
	match input.action:
		
		"END_TURN":
			_handle_end_turn()
			pass
		
		"SACRIFICE_PAWN":
			# input.coords = { x: $, y: $ }
			pass
		
		"CREATE":
			# input.coords =  { x: $, y: $ }
			# input.piece = "Pawn", "Knight", etc.
			# input.color = "Black" or "White" (opponent's color)
			pass
		
		"MOVE":
			# input.from_coords =  { x: $, y: $ } (piece)
			# input.to_coords =  =  { x: $, y: $ } (tile)
			# input.type_of_piece = "Bishop", "Rook", etc.
			pass
		
		_:
			print("Remote input action not recognized")
