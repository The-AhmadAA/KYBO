extends Node

func _ready():
	$UserInterface/Retry.hide()

func _on_boxer1_die():
	$UserInterface/Retry.show()

func _input(event):
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
