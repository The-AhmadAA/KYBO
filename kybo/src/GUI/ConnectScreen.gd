extends Control

# =================== Play ===================
func _on_single_player_pressed() -> void:
	# get_tree().change_scene("res://MainScenes/Level.tscn")
	Global.start_single_player()
	hide()

func _on_host_pressed() -> void:
	Global.create_server()
	hide()

func _on_join_pressed() -> void:
	Global.join_server()
	hide()

# =================== Misc ===================
func _on_options_pressed() -> void:
	print("Jokes on you, there are no options! (Yet)")

func _on_quit_pressed() -> void:
	get_tree().quit()
