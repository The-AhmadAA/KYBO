extends KinematicBody

const LERP_SPEED : float = 0.2

const MAX_HAND_DISTANCE_FROM_FACE : int = 10
const HAND_LEFT_BASE_POSITION : Vector3= Vector3(-1.0, 0, 0) # adjust to your desired base position
const HAND_RIGHT_BASE_POSITION : Vector3 = Vector3(1.0, 0, 0) # adjust to your desired base position

var last_received_left_hand_position = Vector3(0,0,0) # Store the last received left hand position
var last_received_right_hand_position = Vector3(0,0,0) # Store the last received right hand position

var position_history = {
	"Face": [],
	"Hand_Left": [],
	"Hand_Right": []
}

onready var head : KinematicBody = $Face
onready var hand_right : KinematicBody = $Hand_Right
onready var hand_left : KinematicBody = $Hand_Left


func _process(delta):
	# Check that there is an opponent to move
	
	# Move the opponents parts from rcp_unreliable
	# We will need a timestamp on this and use the most updated one
	
	update_hands_position($Face.translation)


func update_hands_position(face_translation: Vector3):
	# calculate hands' position based on face's translation and keep them within bounds
	var left_position = face_translation + HAND_LEFT_BASE_POSITION + last_received_left_hand_position
	var right_position = face_translation + HAND_RIGHT_BASE_POSITION + last_received_right_hand_position

	# Ensure the hands don't move too far from the face
	if left_position.distance_to(face_translation) > MAX_HAND_DISTANCE_FROM_FACE:
		left_position = face_translation + (left_position - face_translation).normalized() * MAX_HAND_DISTANCE_FROM_FACE
	if right_position.distance_to(face_translation) > MAX_HAND_DISTANCE_FROM_FACE:
		right_position = face_translation + (right_position - face_translation).normalized() * MAX_HAND_DISTANCE_FROM_FACE
	
	hand_left.translation = (left_position + Vector3(1.5, 0.0, -4.0))
	hand_right.translation = (right_position + Vector3(1.0, 0.0, -4.0))

func get_position_data(position : Dictionary) -> void:
	pass
