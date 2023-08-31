extends Node

var host  = null
var opponent = null

var network : NetworkedMultiplayerENet
var ip : String = "127.0.0.1"#"10.89.140.109" # "127.0.0.1"
var port : int = 1909
var max_players : int = 2

# =================== Single Player ===================
func start_single_player() -> void:
	get_tree().call_group("Main", "set_character", "Single")
	get_tree().call_group("DEBUG", "_debug_message", "Set up single player, AKA, training mode.")

# =================== Server Hosting ===================
# Host the server

func create_server() -> void:
	# Start the server
	network = NetworkedMultiplayerENet.new()
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	
	# Messages
	get_tree().call_group("DEBUG", "_debug_message", "Server started on " + ip + " on port " + str(port))
	
	# Claim Player 1
	get_tree().call_group("Main", "set_character", "Player1")
	
	# Connect the event of peers dis/connection to their respective functions
	network.connect('peer_connected', self, '_PeerConnected')
	network.connect('peer_disconnected', self, '_PeerDisconnected')

func _PeerConnected(player_id):
	Global.opponent = player_id
	get_tree().call_group("DEBUG", "_debug_message", "Challenger approaches!")
	get_tree().call_group("connection_screen", "hide")

func _PeerDisconnected(_player_id):
	Global.opponent = null
	get_tree().call_group("DEBUG", "_debug_message", "Opponent has fled!")


# =================== Joining Client ===================
func join_server() -> void:
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	# Claim Player2
	get_tree().call_group("Main", "set_character", "Player2")
	
	network.connect('connection_failed', self, '_OnConnectionFailed')
	network.connect('connection_succeeded', self, '_OnConnectionSuccessful')

func _OnConnectionFailed():
	Global.opponent = null
	get_tree().call_group("DEBUG", "_debug_message", "Join failed")
	get_tree().call_group("connection_screen", "show")

func _OnConnectionSuccessful():
	Global.opponent = 1
	get_tree().call_group("DEBUG", "_debug_message", "Join successful")
	get_tree().call_group("connection_screen", "hide")


# =================== State Communication ===================

# Need to:
# Communicate collision (from host side??)

func SendPlayerState(player_state):
	rpc_unreliable_id(opponent, "RecievePlayerState", player_state)
	
remote func RecievePlayerState(player_state):
	get_tree().call_group("opponent", "recieve_state", player_state)
