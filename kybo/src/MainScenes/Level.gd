extends Spatial

func set_character(character : String) -> void:
	# Add script to characters
	# Add group "opponent" to oppenent
	match character:
		# Remove Zuck and replace with dummy for single player?
		"Single", "Musk":
			$Musk.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Zuck.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Musk.add_to_group("player")
			$Zuck.add_to_group("opponent")
			$Musk/Head/Camera.current = true
		"Zuck":
			$Zuck.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Musk.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Musk.add_to_group("opponent")
			$Zuck/Head/Camera.current = true
		_:
			print("Incorrect character")
