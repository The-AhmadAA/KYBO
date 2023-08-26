extends Control

var network : NetworkedMultiplayerENet
var ip = "127.0.0.1"
var port = 1909
var max_players = 2

var host_id = null
var opponent_id = null

onready var DEBUG_LABEL : TextEdit = $DEBUG


func _debug_display_message(message : String) -> void:
	DEBUG_LABEL.text += message + "\n"
	print(message)


# =================== Server Hosting ===================
# Host the server
func _on_HostButton_pressed() -> void:
	network = NetworkedMultiplayerENet.new()
	
	# Start the server
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	
	get_tree().call_group("GUI", "hide")
	_debug_display_message("Server started on " + ip + " on port " + str(port))
	
	# Connect the event of peers dis/connection to their respective functions
	network.connect('peer_connected', self, '_PeerConnected')
	network.connect('peer_disconnected', self, '_PeerDisconnected')

func _PeerConnected(player_id):
	opponent_id = player_id
	_debug_display_message("Challenger approaches!")

func _PeerDisconnected(player_id):
	opponent_id = null
	# Idea is to just have one player that you are against.
	# So the player can just stay there and not go into complex instantiation
	_debug_display_message("Opponent has fled!")


# =================== Joining Client ===================
func _on_JoinButton_pressed() -> void:
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect('connection_failed', self, '_OnConnectionFailed')
	network.connect('connection_succeeded', self, '_OnConnectionSuccessful')

func _OnConnectionFailed():
	get_tree().call_group('GUI', 'show')
	get_tree().call_group('GUI', '')
	
	_debug_display_message("Join Failed")

func _OnConnectionSuccessful():
	get_tree().call_group("GUI", "hide")
	
	_debug_display_message("Join successful")
