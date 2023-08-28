import pyrealsense2 as rs
import mediapipe as mp
import cv2
import numpy as np
import socket
import atexit
from classes import Server, Realsense, MediaPipeProcessor
from helpers import cleanup, normalize_coordinates

def main():
    server = Server()
    realsense = Realsense()
    processor = MediaPipeProcessor()

    atexit.register(lambda: cleanup(server, realsense))

    server.start()
    print(f"Connected, starting to capture images on SN: {realsense.device}")

    while True:
        try:
            aligned_frames = realsense.get_frames()
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
            results = processor.process_hands(color_images_rgb_flipped)
            if results.multi_hand_landmarks:
                for idx, handLms in enumerate(results.multi_hand_landmarks):
                    hand_side_classification_list = results.multi_handedness[idx]
                    hand_side = hand_side_classification_list.classification[0].label

                    centroid_x, centroid_y = processor.calculate_hand_centroid(handLms)
            
                    x = int(centroid_x * width)
                    y = int(centroid_y * height)
                    
                    # Sample from a region around the centroid incase wrong values
                    # Let's consider a 5x5 region around the centroid
                    depth_values = []
                    for i in range(-2, 3):  # considering 5 pixels in x direction
                        for j in range(-2, 3):  # considering 5 pixels in y direction
                            if 0 <= y+j < height and 0 <= x+i < width:
                                depth_value = depth_image_flipped[y+j, x+i] * realsense.depth_scale
                                if depth_value > 0:  # discard invalid depth values
                                    depth_values.append(depth_value)
                    if not depth_values:
                        continue  # continue if there are no valid depth values

                    # Calculate the average depth from the sampled region.
                    avg_distance = sum(depth_values) / len(depth_values)

                    # # Clamp the distance between 0 and 1 meters
                    clamped_distance = min(max(avg_distance, 0), 1)

                    # Normalize the clamped distance to be between 0 and 3
                    normalized_distance =  3 * (clamped_distance / 1)

                    norm_x, norm_y = normalize_coordinates(x, y, realsense.resolution[0], realsense.resolution[1])

                    server.send_data(f"Hand_{hand_side},{round(norm_x, 8)},{-round(norm_y, 8)}, {round(normalized_distance, 8)}!!\n".encode())
                    # print(f"Hand_{hand_side}")

            face_results = processor.process_face(color_images_rgb)
            if face_results.multi_face_landmarks:
                for faceLms in face_results.multi_face_landmarks:
                    # Compute the center between the two eyes
                    center_x = int((faceLms.landmark[33].x + faceLms.landmark[263].x) * 0.5 * len(depth_image[0]))
                    center_y = int((faceLms.landmark[33].y + faceLms.landmark[263].y) * 0.5 * len(depth_image))
                    
                    # Ensure center_x and center_y are within bounds of image
                    center_x = min(max(center_x, 0), width - 1)
                    center_y = min(max(center_y, 0), height - 1)
                    
                    # Grab the distance for depth_image and that co-ord
                    center_distance = depth_image[center_y, center_x] * realsense.depth_scale

                    # Clamp the distance between -1 and 4 meters
                    clamped_distance = min(max(center_distance, 0), 5) - 1

                    # Normalize the clamped distance
                    normalized_distance = clamped_distance #2 * (clamped_distance / 5)
                    
                    norm_x, norm_y = normalize_coordinates(center_x, center_y, realsense.resolution[0], realsense.resolution[1])

                    server.send_data(f"Face,{-round(norm_x, 8)},{-round(norm_y, 8)},{round(normalized_distance, 5)}!!\n".encode())


        except (ConnectionResetError, ConnectionRefusedError, ConnectionAbortedError):
            print("Connection lost... Restarting.")
            server.close()
            server.start()




if __name__ == "__main__":
    main()