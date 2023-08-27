extends Control

var network : NetworkedMultiplayerENet
var ip : String = "127.0.0.1"
var port : int = 1909
var max_players : int = 2

onready var DEBUG_LABEL : TextEdit = $DEBUG
onready var gui : ColorRect = $ConnectionButtons


func _debug_display_message(message : String) -> void:
	DEBUG_LABEL.text += message + "\n"
	print(message)


# Sorry, threw it all in one script for now XD
# Should be sepparted into 2 scripts (host & client)
# And have these scripts added to the root scene depending on button pressed


# =================== Server Hosting ===================
# Host the server
func _on_HostButton_pressed() -> void:
	network = NetworkedMultiplayerENet.new()
	
	# Start the server
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	
	_debug_display_message("Server started on " + ip + " on port " + str(port))
	gui.hide()
	
	# Connect the event of peers dis/connection to their respective functions
	network.connect('peer_connected', self, '_PeerConnected')
	network.connect('peer_disconnected', self, '_PeerDisconnected')

func _PeerConnected(player_id):
	Global.opponent = player_id
	_debug_display_message("Challenger approaches!")

func _PeerDisconnected(player_id):
	Global.opponent = null
	_debug_display_message("Opponent has fled!")


# =================== Joining Client ===================
func _on_JoinButton_pressed() -> void:
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect('connection_failed', self, '_OnConnectionFailed')
	network.connect('connection_succeeded', self, '_OnConnectionSuccessful')

func _OnConnectionFailed():
	_debug_display_message("Join Failed")
	gui.show()

func _OnConnectionSuccessful():
	_debug_display_message("Join successful")
	gui.hide()


# =================== State Communication ===================

# Need to:
# Update the opponent to host position
# Update the host to the opponent position
# Communicate collision (from host side??)

func send_state():
	# Send posistion of hands, and head in global(?) space?
	# call the player node to send this into
	pass

func get_state():
	# Get position of hands
	pass
