extends KinematicBody

const PORT : int = 65445
const MAX_RETRY : int = 5
const HISTORY_SIZE : int = 5
const LERP_SPEED : float = 0.2

const MAX_HAND_DISTANCE_FROM_FACE : int = 10
const HAND_LEFT_BASE_POSITION : Vector3= Vector3(-1.0, 0, 0) # adjust to your desired base position
const HAND_RIGHT_BASE_POSITION : Vector3 = Vector3(1.0, 0, 0) # adjust to your desired base position

var client = StreamPeerTCP.new()
var buffer = ""
var current_retry = 0

var last_received_left_hand_position = Vector3(0,0,0) # Store the last received left hand position
var last_received_right_hand_position = Vector3(0,0,0) # Store the last received right hand position

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


onready var head : MeshInstance = $Face
onready var hand_right : KinematicBody = $Hand_Right
onready var hand_left : KinematicBody = $Hand_Left


func normalize_position(pos: Vector3) -> Vector3:
	return (pos - Vector3(0.5, 0.5, 0.5)) * 2

func array_to_string(arr: Array) -> String:
	var s = ""
	for i in arr:
		s += char(i)
	return s

func _ready():
	var error = client.connect_to_host("127.0.0.1", PORT)
	if error == OK:
		print("Successfully connected to server!")
	else:
		printerr("Failed to connect to server. Error: ", error)
		
	last_update["Face"] = OS.get_system_time_msecs()
	last_update["Hand_Left"] = OS.get_system_time_msecs()
	last_update["Hand_Right"] = OS.get_system_time_msecs()

func update_hands_position(face_translation: Vector3):
	# calculate hands' position based on face's translation and keep them within bounds
	if OS.get_system_time_msecs() - last_update['Hand_Left'] > 100 and position_history["Hand_Left"].size() > 1:
		last_received_left_hand_position -= position_history["Hand_Left"][-2] - position_history["Hand_Left"][-1]
	
	if OS.get_system_time_msecs() - last_update['Hand_Right'] > 100 and position_history["Hand_Right"].size() > 1:
		last_received_right_hand_position -= position_history["Hand_Right"][-2] - position_history["Hand_Right"][-1]
	
	
	var left_position = face_translation + HAND_LEFT_BASE_POSITION + last_received_left_hand_position
	var right_position = face_translation + HAND_RIGHT_BASE_POSITION + last_received_right_hand_position

	# Ensure the hands don't move too far from the face
	if left_position.distance_to(face_translation) > MAX_HAND_DISTANCE_FROM_FACE:
		left_position = face_translation + (left_position - face_translation).normalized() * MAX_HAND_DISTANCE_FROM_FACE
	if right_position.distance_to(face_translation) > MAX_HAND_DISTANCE_FROM_FACE:
		right_position = face_translation + (right_position - face_translation).normalized() * MAX_HAND_DISTANCE_FROM_FACE
	
	hand_left.translation = (left_position + Vector3(1.5, 0.0, -4.0))
	hand_right.translation = (right_position + Vector3(1.0, 0.0, -4.0))

func _process(delta):
	if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		if client.get_available_bytes() > 0:  # Check if there's data available
			var data = client.get_data(100) # Adjust buffer size if necessary
			var received_str = array_to_string(data[1])
			buffer += received_str 
			
			while "!!" in buffer:
				var index = buffer.find("!!\n")
				var message = buffer.substr(0, index)  # Extract the complete message
				buffer = buffer.substr(index + 3)  # Update buffer to hold data after the delimiter
				
				#print("Complete message:", message) # Debug print
				var decoded_data = message.split(",")
				# Update position history
				if decoded_data.size() >= 4:
					var type = decoded_data[0]
					if !(type in ['Hand_Left', 'Hand_Right', 'Face']):
						continue
					var position = Vector3(float(decoded_data[1]), float(decoded_data[2]), float(decoded_data[3]))
					
					# Store to history
					if type in position_history and position_history[type].size() >= HISTORY_SIZE:
						position_history[type].pop_front()
					position_history[type].append(position)
					
					# Calculate averaged position based on past few frames for smoothing
					var averaged_position = Vector3()
					for pos in position_history[type]:
						averaged_position += pos
					averaged_position /= position_history[type].size()
					
					if type == "Face":
						var target_translation = averaged_position.linear_interpolate(translation, LERP_SPEED)
						$Face.translation = target_translation
						#update_hands_position(target_translation)
					elif type == "Hand_Left":
						last_received_left_hand_position = normalize_position(averaged_position)
						last_update["Hand_Left"] = OS.get_system_time_msecs()
					elif type == "Hand_Right":
						last_received_right_hand_position = normalize_position(averaged_position)
						last_update["Hand_Right"] = OS.get_system_time_msecs()
						
						
					update_hands_position($Face.translation)
	
	else:
		if current_retry == 0:
			print("Disconnected from server")
		var error = client.connect_to_host("localhost", PORT)
		if error == OK:
			print("Reconnected to server!")
			current_retry = 0
		current_retry += 1
