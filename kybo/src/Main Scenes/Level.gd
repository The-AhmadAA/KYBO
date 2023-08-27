extends Spatial

func set_character(character : String) -> void:
	# Add script to characters
	# Add group "opponent" to oppenent
	match character:
		"Musk":
			$Musk.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Zucc.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Zucc.add_to_group("opponent")
		"Zucc":
			$Zucc.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Musk.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Musk.add_to_group("opponent")
