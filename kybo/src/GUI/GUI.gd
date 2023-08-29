extends Control


func _ready() -> void:
	$Reconnect.hide()

func _on_connect_pressed() -> void:
	get_tree().call_group("player", "reset_retry")
