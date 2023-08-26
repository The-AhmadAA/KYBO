extends KinematicBody

var client = StreamPeerTCP.new()

# Child nodes
var port = 65442
var hand_left
var hand_right
var head
var buffer = ""
var maximum_retry = 5
var current_retry = 0

func array_to_string(arr: Array) -> String:
	var s = ""
	for i in arr:
		s += char(i)
	return s


func _ready():
	hand_left = $Hand_Left # Adjust this to your actual node name
	hand_right = $Hand_Right # Adjust this to your actual node name
	head = $Face # Adjust this to your actual node name
	
	var error = client.connect_to_host("localhost", port)
	if error == OK:
		print("Successfully connected to server!")
	else:
		printerr("Failed to connect to server. Error: ", error)
		
		
		
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
				
				print("Complete message:", message) # Debug print
				var decoded_data = message.split(",")
				if decoded_data.size() >= 4: # Ensure we have enough data points
					var type = decoded_data[0]
					var position = Vector3(float(decoded_data[1]), float(decoded_data[2]), float(decoded_data[3]))
					
					print("Processed data for type:", type, ". Position:", position) # Debug print
					# Map the position data to the respective node
					if type == "Hand_Left" :
						hand_left.translation = position
					elif type == "Hand_Right":
						hand_right.translation = position
					elif type == "Face":
						head.translation = position
					else:
						printerr("Unknown type received:", type)
					
				else:
					printerr("Incomplete data received:", message)
	else:
		if current_retry == 0:
			print("Disconnected from server")
		var error = client.connect_to_host("localhost", port)
		if error == OK:
			print("Reconnected to server!")
			current_retry = 0
		current_retry += 1
