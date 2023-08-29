import cv2
import atexit
from classes import Server, MediaPipeProcessor
from helpers import *


def main():
    args = parse_args()
    display_window = args.display
    no_server = args.noserver

    server = Server()
    processor = MediaPipeProcessor()
    camera = cv2.VideoCapture(0)

    if not camera.isOpened():
        print("Could not open webcam!")
        return


    atexit.register(lambda: cleanup(server, camera=camera))

    if not no_server:
        server.start()
    print(f"Connected, starting to capture images...")

    # hand_area_history = []
    # face_boxes_history = []
    # left_hand_boxes_history = []
    # right_hand_boxes_history = []

    HISTORY_SIZE = 10
    box_history = { "Left" : [], "Right" : [], 'Face' : []}

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

                    hand_bounding_box = get_bounding_box(handLms)
                    box_history[hand_side].append(hand_bounding_box)

                    centroid_x, centroid_y = get_center_of_box(*hand_bounding_box)
                    x = int(centroid_x * width)
                    y = int(centroid_y * height)

                    is_punching = False
                    if len(box_history[hand_side]) > HISTORY_SIZE:
                        box_history[hand_side].pop(0)
                        
                    if len(box_history[hand_side]) == HISTORY_SIZE:
                        average_recent = calculate_box_area(*average_boxes(box_history[hand_side][-(HISTORY_SIZE//2):]))
                        average_preceding = calculate_box_area(*average_boxes(box_history[hand_side][-HISTORY_SIZE:-(HISTORY_SIZE//2)]))

                        if average_recent > 1.3 * average_preceding:  # Changed to 1.1 (or 110%) for more sensitivity
                            is_punching = True

                    norm_x, norm_y = normalize_coordinates(x, y, width, height)

                    #print(f"Hand_{hand_side},{round(norm_x, 8)},{-round(norm_y, 8)},punching:{(1 if is_punching else 0)}!!\n")
                    if not no_server:
                        server.send_data(f"Hand_{hand_side},{round(norm_x, 8)},{-round(norm_y, 8)},{(1 if is_punching else 0)}!!\n".encode())

                    if display_window:
                        x = width - int(centroid_x * width)
                        y = int(centroid_y * height)
                        cv2.circle(frame, (x, y), 10, (0, 255, 0), -1)
                        cv2.putText(frame, "Punching" if is_punching else "Not Punching", (x+20, y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)



            # Processing face =
            face_results = processor.process_face(color_images_rgb_flipped)
            if face_results.multi_face_landmarks:
                for faceLms in face_results.multi_face_landmarks:
                    bounding_box = get_bounding_box(faceLms)
                    box_history['Face'].append(bounding_box)

                    is_blocking = False
                    if len(box_history['Face']) > HISTORY_SIZE:
                        box_history['Face'].pop(0)

                    if len(box_history['Face']) == HISTORY_SIZE:
                        pass # Do some calculations here
                    
                    if box_history['Right'] and box_history['Left']:
                        avg_face_box = average_boxes(box_history['Face'])

                        avg_left_hand_box = average_boxes(box_history["Left"])
                        left_overlap = get_overlap(avg_face_box, avg_left_hand_box)
                        
                        avg_right_hand_box = average_boxes(box_history["Right"])
                        right_overlap = get_overlap(avg_face_box, avg_right_hand_box)

                        face_area = calculate_box_area(*avg_face_box)

                        is_blocking = left_overlap > 0.1 * face_area and right_overlap > 0.1 * face_area      

                        if display_window:
                            normalize_display_box(frame, avg_face_box, width, height, (0, 255, 255)) 
                            normalize_display_box(frame, avg_right_hand_box, width, height, (255, 255, 0))
                            normalize_display_box(frame, avg_left_hand_box, width, height, (255, 255, 0))
        
                    centroid_x, centroid_y = get_center_of_box(*bounding_box)
                    x = int(centroid_x * width)
                    y = int(centroid_y * height)
                    norm_x, norm_y = normalize_coordinates(x, y, width, height)

                    #print(f"Face,{-round(norm_x, 8)},{-round(norm_y, 8)}!!\n")
                    if not no_server:
                        server.send_data(f"Face,{-round(norm_x, 8)},{-round(norm_y, 8)},{1 if is_blocking else 0}!!\n".encode())

                    if display_window:
                        x = width - int(centroid_x * width)
                        y = int(centroid_y * height)
                        cv2.circle(frame, (x, y), 10, (255, 0, 0), -1)
                        cv2.putText(frame, "Blocking" if is_blocking else "Not Blocking", (x, y), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 1)
                        

            if display_window:
                cv2.imshow("Webcam", frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break

        except (ConnectionResetError, ConnectionRefusedError, ConnectionAbortedError):
            print("Connection lost... Restarting.")
            server.close()
            server.start()

if __name__ == "__main__":
    main()
