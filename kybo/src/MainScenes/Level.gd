extends Spatial

func set_character(character : String) -> void:
	# Add script to characters
	# Add group "opponent" to oppenent
	match character:
		# Remove Player2 and replace with dummy for single player?
		"Single", "Player1":
			Global.opponent_name = "Player2"
			$Player1.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Player1/Head/Camera.current = true
			$Player1.add_to_group("player")
			
			$Player2.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Player2.add_to_group("opponent")
			
			($Player1/HitBox as Area).set_collision_mask_bit(1, true)
			
		"Player2":
			Global.opponent_name = "Player1"
			$Player2.set_script(load("res://Boxer/RealsenseBoxer.gd"))
			$Player2/Head/Camera.current = true
			$Player2.add_to_group("player")
			
			$Player1.set_script(load("res://Boxer/OpponentBoxer.gd"))
			$Player1.add_to_group("opponent")
			
			($Player2/HitBox as Area).set_collision_mask_bit(0, true)
		_:
			print("Incorrect character")
