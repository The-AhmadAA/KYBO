extends Boxer

var prev_time_recieved = 0

var last_recieved : Dictionary = {
	"Face" : 0,
	"Hand_Left" : 0,
	"Hand_Right" : 0
}


func _init() -> void:
	head = $Head
	hand_right = $Hand_Right
	hand_left = $Hand_Left
	
	set_process(true)

func _process(_delta):
	# Check that there is an opponent to move
	if Global.opponent != null:
		update_hands_position()

func recieve_state(player_state) -> void:
	var time = player_state['time']
	var position = Vector3(0, 0, 0)
	if prev_time_recieved < time:
		for type in ['Hand_Left', 'Hand_Right', 'Face']:
			position = player_state[type]
			if type in position_history and position_history[type].size() >= HISTORY_SIZE:
				position_history[type].pop_front()
			position_history[type].append(position)
		prev_time_recieved = time

func update_hands_position():
	if prev_time_recieved > 0:
		head.translation = position_history['Face'][-1] 
		hand_left.translation = position_history['Hand_Left'][-1] + Vector3(0, 0, 1.0)
		hand_right.translation = position_history['Hand_Right'][-1] + Vector3(0, 0, 1.0)
