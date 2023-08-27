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


onready var head : MeshInstance = $Face
onready var hand_right : KinematicBody = $Hand_Right
onready var hand_left : KinematicBody = $Hand_Left


func _process(delta):
	# Check that there is an opponent to move
	update_hands_position($Face.translation)

func recieve_state(player_state) -> void:
	var type = player_state['state']
	var time = player_state['time']
	var position = player_state['position']
	
	if last_recieved[type] < time:
		last_recieved[type] = time
		last_update[type] = OS.get_ticks_msec()
		# Store to history
		if type in position_history and position_history[type].size() >= HISTORY_SIZE:
			position_history[type].pop_front()
		position_history[type].append(position)
	

func update_hands_position():
	# calculate hands' position based on face's translation and keep them within bounds
	var left_position = face_translation + HAND_LEFT_BASE_POSITION + last_received_left_hand_position
	var right_position = face_translation + HAND_RIGHT_BASE_POSITION + last_received_right_hand_position

	var averaged_position = Vector3()
	# Ensure the hands don't move too far from the face
	if left_position.distance_to(face_translation) > MAX_HAND_DISTANCE_FROM_FACE:
		left_position = face_translation + (left_position - face_translation).normalized() * MAX_HAND_DISTANCE_FROM_FACE
	if right_position.distance_to(face_translation) > MAX_HAND_DISTANCE_FROM_FACE:
		right_position = face_translation + (right_position - face_translation).normalized() * MAX_HAND_DISTANCE_FROM_FACE
	
	hand_left.translation = (left_position + Vector3(1.5, 0.0, -4.0))
	hand_right.translation = (right_position + Vector3(1.0, 0.0, -4.0))

func get_position_data(position : Dictionary) -> void:
	pass
