extends Spatial

func set_character(character : String) -> void:
	# Add script to characters
	# Add group "opponent" to oppenent
	match character:
		# Remove Zuck and replace with dummy for single player?
		"Single", "Musk":
			$Musk.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Zucc.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Zucc.add_to_group("opponent")
			$Musk/Face/Camera.current = true
		"Zucc":
			$Zucc.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Musk.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Musk.add_to_group("opponent")
			$Zucc/Face/Camera.current = true
		_:
			print("Incorrect character")
