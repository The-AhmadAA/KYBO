extends Control

onready var DEBUG_LABEL : TextEdit = $DEBUG

func _debug_display_message(message : String) -> void:
	DEBUG_LABEL.text += message + "\n"
	print(message)

func _on_HostButton_pressed() -> void:
	Global.create_server()
	get_node("Screen").visible = false

func _on_JoinButton_pressed() -> void:
	Global.join_server()
	get_node("Screen").visible = false
