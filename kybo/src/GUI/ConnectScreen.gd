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

# =================== Server Hosting ===================
# Host the server
func _on_HostButton_pressed() -> void:
	Global.create_server()


# =================== Joining Client ===================
func _on_JoinButton_pressed() -> void:
	Global.join_server()

