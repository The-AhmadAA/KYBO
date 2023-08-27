extends KinematicBody

const LERP_SPEED : float = 0.2
const HISTORY_SIZE : int = 5
const MAX_HAND_DISTANCE_FROM_FACE : int = 10
const HAND_LEFT_BASE_POSITION : Vector3= Vector3(-1.0, 0, 0) # adjust to your desired base position
const HAND_RIGHT_BASE_POSITION : Vector3 = Vector3(1.0, 0, 0) # adjust to your desired base position

var position_history = {
	"Face": [],
	"Hand_Left": [],
	"Hand_Right": []
}

var last_update = {
	"Face" : 0,
	"Hand_Left" : 0,
	"Hand_Right" : 0
}

var last_recieved = {
	"Face" : 0,
	"Hand_Left" : 0,
	"Hand_Right" : 0
}

var prev_time_recieved = 0


onready var head : MeshInstance = $Face
onready var hand_right : KinematicBody = $Hand_Right
onready var hand_left : KinematicBody = $Hand_Left


func _process(delta):
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
	#var type = player_state['state']
	#var time = player_state['time']
	#var position = player_state['position']
	
	#if last_recieved[type] < time:
	#	last_recieved[type] = time
	#	last_update[type] = OS.get_ticks_msec()
	#	# Store to history
	#	if type in position_history and position_history[type].size() >= HISTORY_SIZE:
	#		position_history[type].pop_front()
	#	position_history[type].append(position)
		
	

func update_hands_position():
	#var offset = 0
	# calculate hands' position based on face's translation and keep them within bounds
	#if OS.get_system_time_msecs() - last_update['Hand_Left'] > 100 and position_history["Hand_Left"].size() > 1:
	#	offset = position_history["Hand_Left"][-2] - position_history["Hand_Left"][-1]
	
	#if OS.get_system_time_msecs() - last_update['Hand_Right'] > 100 and position_history["Hand_Right"].size() > 1:
	#	offset = position_history["Hand_Right"][-2] - position_history["Hand_Right"][-1]
	
	#var averaged_position = Vector3()
	#var new_positions = {'Hand_Left' : 0, 'Hand_Right' : 0, 'Face' : 0}
	#for type in ['Hand_Left', 'Hand_Right', 'Face']:
	#	for pos in position_history[type]:
	#		averaged_position += pos
	#	averaged_position /= position_history[type].size()
	if prev_time_recieved > 0:
		head.translation = position_history['Face'][-1] 
		hand_left.translation = position_history['Hand_Left'][-1]
		hand_right.translation = position_history['Hand_Right'][-1]
