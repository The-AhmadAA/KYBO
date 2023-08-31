extends Spatial

func set_character(character : String) -> void:
	# Add script to characters
	# Add group "opponent" to oppenent
	match character:
		# Remove Player2 and replace with dummy for single player?
		"Single", "Player1":
			$Player1.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Player2.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Player2.add_to_group("opponent")
			$Player1.add_to_group("player")
			$Player1/Head/Camera.current = true
		"Player2":
			$Player1.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Player1.add_to_group("opponent")
			$Player2.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Player2/Head/Camera.current = true
		_:
			print("Incorrect character")
