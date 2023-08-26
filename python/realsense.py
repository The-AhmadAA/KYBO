import pyrealsense2 as rs
import mediapipe as mp
import cv2
import numpy as np
import socket
import atexit, time

def normalize_coordinates(x, y, frame_width, frame_height):
    normalized_x = (x - frame_width / 2) / (frame_width / 2)
    normalized_y = (y - frame_height / 2) / (frame_height / 2)
    return normalized_x, normalized_y



def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('127.0.0.1', 65445))
    server_socket.listen()

    print("Waiting for Godot...")
    conn, addr = server_socket.accept()
    
    return conn, server_socket


# ====== Realsense ======
realsense_ctx = rs.context()
connected_devices = [realsense_ctx.devices[i].get_info(rs.camera_info.serial_number) for i in range(len(realsense_ctx.devices))]
device = connected_devices[0]  # In this example we are only using one camera
pipeline = rs.pipeline()
config = rs.config()

# ====== Mediapipe ======
mpHands = mp.solutions.hands
hands = mpHands.Hands()

mpFace = mp.solutions.face_mesh
face = mpFace.FaceMesh()


# ====== Enable Streams ======
config.enable_device(device)
stream_res_x = 640
stream_res_y = 480
stream_fps = 30

config.enable_stream(rs.stream.depth, stream_res_x, stream_res_y, rs.format.z16, stream_fps)
config.enable_stream(rs.stream.color, stream_res_x, stream_res_y, rs.format.bgr8, stream_fps)
profile = pipeline.start(config)

align_to = rs.stream.color
align = rs.align(align_to)




# ====== Get depth Scale ======
depth_sensor = profile.get_device().first_depth_sensor()
depth_scale = depth_sensor.get_depth_scale()

def cleanup():
    print("Cleaning up...")
    try:
        conn.close()
        server_socket.close()
        pipeline.stop()
    except:
        pass
    print("Cleanup completed!")

atexit.register(cleanup)

# ====== Run the code ======== #
conn, server_socket = start_server()

print(f"Connected, starting to capture images on SN: {device}")

def calculate_hand_centroid(handLms):
    x = sum([lm.x for lm in handLms.landmark]) / len(handLms.landmark)
    y = sum([lm.y for lm in handLms.landmark]) / len(handLms.landmark)
    return x, y


# Your main loop
while True:
    try:
        # Get and align frames
        frames = pipeline.wait_for_frames()
        aligned_frames = align.process(frames)
        aligned_depth_frame = aligned_frames.get_depth_frame()
        color_frame = aligned_frames.get_color_frame()
        
        if not aligned_depth_frame or not color_frame:
            continue

        # Process images
        depth_image = np.asanyarray(aligned_depth_frame.get_data())
        depth_image_flipped = cv2.flip(depth_image, 1)
        color_image = np.asanyarray(color_frame.get_data())
        color_images_rgb = cv2.cvtColor(color_image, cv2.COLOR_BGR2RGB)
        color_images_rgb_flipped = cv2.flip(color_images_rgb, 1)

        height, width = depth_image_flipped.shape

        # Process hands
        results = hands.process(color_images_rgb_flipped)
        if results.multi_hand_landmarks:
            for idx, handLms in enumerate(results.multi_hand_landmarks):
                hand_side_classification_list = results.multi_handedness[idx]
                hand_side = hand_side_classification_list.classification[0].label

                centroid_x, centroid_y = calculate_hand_centroid(handLms)
        
                x = int(centroid_x * len(depth_image_flipped[0]))
                y = int(centroid_y * len(depth_image_flipped))
                
                # Sample from a region around the centroid for a more robust depth measurement.
                # Let's consider a 5x5 region around the centroid for simplicity.
                depth_values = []
                for i in range(-2, 3):  # considering 5 pixels in x direction
                    for j in range(-2, 3):  # considering 5 pixels in y direction
                        if 0 <= y+j < height and 0 <= x+i < width:
                            depth_value = depth_image_flipped[y+j, x+i] * depth_scale
                            if depth_value > 0:  # discard invalid depth values
                                depth_values.append(depth_value)
                if not depth_values:
                    continue  # continue if there are no valid depth values

                # Calculate the average depth from the sampled region.
                avg_distance = sum(depth_values) / len(depth_values)

                # # Clamp the distance between 0 and 1 meters
                clamped_distance = min(max(avg_distance, 0), 1)

                # print(f"Hand_{hand_side} - Distance: {avg_distance}")
                # # Normalize the clamped distance to be between -1 and 1
                normalized_distance =  3 * (clamped_distance / 1)
                # normalized_distance = avg_distance

                norm_x, norm_y = normalize_coordinates(x, y, stream_res_x, stream_res_y)

                conn.sendall(f"Hand_{hand_side},{round(norm_x, 8)},{-round(norm_y, 8)}, {round(normalized_distance, 8)}!!\n".encode())
                # print(f"Hand_{hand_side}")

        face_results = face.process(color_images_rgb)
        if face_results.multi_face_landmarks:
            for faceLms in face_results.multi_face_landmarks:
                center_x = int((faceLms.landmark[33].x + faceLms.landmark[263].x) * 0.5 * len(depth_image[0]))
                center_y = int((faceLms.landmark[33].y + faceLms.landmark[263].y) * 0.5 * len(depth_image))
                
                center_x = min(max(center_x, 0), width - 1)
                center_y = min(max(center_y, 0), height - 1)
                
                center_distance = depth_image[center_y, center_x] * depth_scale

                # Clamp the distance between 0 and 5 meters
                clamped_distance = min(max(center_distance, 0), 5) - 1

                # Normalize the clamped distance to be between -1 and 1
                normalized_distance = clamped_distance #2 * (clamped_distance / 5)
                norm_x, norm_y = normalize_coordinates(center_x, center_y, stream_res_x, stream_res_y)

                conn.sendall(f"Face,{-round(norm_x, 8)},{-round(norm_y, 8)},{round(normalized_distance, 5)}!!\n".encode())
                # print(f"Face: {norm_x},{norm_y}")
                #print(f"Face Center (x: {center_x}, y: {center_y}), Distance: {center_distance:.3f} meters")

    except (ConnectionResetError, ConnectionRefusedError, ConnectionAbortedError): 
        print("Connection lost... Restarting.")
        conn.close()
        server_socket.close()
        print("Waiting for Godot")
        conn, server_socket = start_server()