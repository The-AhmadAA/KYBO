import mediapipe as mp
import cv2
import socket
import atexit
from classes import Server, MediaPipeProcessor
from helpers import cleanup, normalize_coordinates

def main():
    server = Server()
    processor = MediaPipeProcessor()
    camera = cv2.VideoCapture(0)

    if not camera.isOpened():
        print("Could not open webcam!")
        return


    atexit.register(lambda: cleanup(server, camera=camera))

    #server.start()
    print(f"Connected, starting to capture images...")

    while True:
        try:
            ret, frame = camera.read()  # Read from webcam
            if not ret:
                print("Failed to grab frame")
                break
            color_images_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            color_images_rgb_flipped = cv2.flip(color_images_rgb, 1)

            height, width = color_images_rgb_flipped.shape[:2]

            # Process hands
            results = processor.process_hands(color_images_rgb_flipped)
            if results.multi_hand_landmarks:
                for idx, handLms in enumerate(results.multi_hand_landmarks):
                    hand_side_classification_list = results.multi_handedness[idx]
                    hand_side = hand_side_classification_list.classification[0].label

                    centroid_x, centroid_y = processor.calculate_hand_centroid(handLms)
                    x = int(centroid_x * width)
                    y = int(centroid_y * height)

                    thumb_tip = handLms.landmark[4]
                    index_tip = handLms.landmark[8]
                    distance = ((thumb_tip.x - index_tip.x) ** 2 + (thumb_tip.y - index_tip.y) ** 2) ** 0.5
                    
                    # Check if the hand is open or closed based on distance of the thumb and index finger
                    hand_state = "Open" if distance > 0.1 else "Closed"  # 0.1 is a heuristic threshold and may need adjustment

                    norm_x, norm_y = normalize_coordinates(x, y, width, height)

                    print(f"Hand_{hand_side},{round(norm_x, 8)},{-round(norm_y, 8)},state:{hand_state}!!\n")
                    # server.send_data(f"Hand_{hand_side},{round(norm_x, 8)},{-round(norm_y, 8)},state:{hand_state}!!\n".encode())

            # Processing face =
            face_results = processor.process_face(color_images_rgb_flipped)
            if face_results.multi_face_landmarks:
                for faceLms in face_results.multi_face_landmarks:
                    center_x = int((faceLms.landmark[33].x + faceLms.landmark[263].x) * 0.5 * width)
                    center_y = int((faceLms.landmark[33].y + faceLms.landmark[263].y) * 0.5 * height)
                    center_x = min(max(center_x, 0), width - 1)
                    center_y = min(max(center_y, 0), height - 1)
                    
                    norm_x, norm_y = normalize_coordinates(center_x, center_y, width, height)
                    print(f"Face,{-round(norm_x, 8)},{-round(norm_y, 8)}!!\n")
                    #server.send_data(f"Face,{-round(norm_x, 8)},{-round(norm_y, 8)}!!\n".encode())

        except (ConnectionResetError, ConnectionRefusedError, ConnectionAbortedError):
            print("Connection lost... Restarting.")
            server.close()
            server.start()

if __name__ == "__main__":
    main()
