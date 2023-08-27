extends Node

var host  = null
var opponent = null

var network : NetworkedMultiplayerENet
var ip : String = "10.89.140.109" # "127.0.0.1"
var port : int = 1909
var max_players : int = 2


# =================== Server Hosting ===================
# Host the server

func create_server() -> void:
	# Start the server
	network = NetworkedMultiplayerENet.new()
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	
	# Messages
	get_tree().call_group("DEBUG", "_debug_display_message", "Server started on " + ip + " on port " + str(port))
	get_tree().call_group("connection_screen", "hide")
	
	# Connect the event of peers dis/connection to their respective functions
	network.connect('peer_connected', self, '_PeerConnected')
	network.connect('peer_disconnected', self, '_PeerDisconnected')

func _PeerConnected(player_id):
	Global.opponent = player_id
	get_tree().call_group("DEBUG", "_debug_display_message", "Challenger approaches!")
	get_tree().call_group("connection_screen", "hide")

func _PeerDisconnected(_player_id):
	Global.opponent = null
	get_tree().call_group("DEBUG", "_debug_display_message", "Opponent has fled!")


# =================== Joining Client ===================
func join_server() -> void:
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect('connection_failed', self, '_OnConnectionFailed')
	network.connect('connection_succeeded', self, '_OnConnectionSuccessful')

func _OnConnectionFailed():
	get_tree().call_group("DEBUG", "_debug_display_message", "Join failed")
	get_tree().call_group("connection_screen", "show")

func _OnConnectionSuccessful():
	get_tree().call_group("DEBUG", "_debug_display_message", "Join successful")
	get_tree().call_group("connection_screen", "hide")


# =================== State Communication ===================

# Need to:
# Update the opponent to host position
# Update the host to the opponent position
# Communicate collision (from host side??)

func SendPlayerState(player_state):
	rpc_unreliable_id(opponent, "RecievePlayerState", player_state)
	
remote func RecievePlayerState(player_state):
	get_tree().call_group("opponent", "recieve_state", player_state)
