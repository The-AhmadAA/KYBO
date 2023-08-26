import pyrealsense2 as rs
import mediapipe as mp
import cv2
import numpy as np

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

print(f"Starting to capture images on SN: {device}")

while True:
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

    # Process hands
    results = hands.process(color_images_rgb)
    if results.multi_hand_landmarks:
        for idx, handLms in enumerate(results.multi_hand_landmarks):
            hand_side_classification_list = results.multi_handedness[idx]
            hand_side = hand_side_classification_list.classification[0].label
            middle_finger_knuckle = handLms.landmark[9]
            x = int(middle_finger_knuckle.x * len(depth_image_flipped[0]))
            y = int(middle_finger_knuckle.y * len(depth_image_flipped))
            mfk_distance = depth_image_flipped[y,x] * depth_scale  # meters
            print(f"{hand_side} Hand Midpoint (x: {x}, y: {y}), Distance: {mfk_distance:.3f} meters")

    face_results = face.process(color_images_rgb)
    if face_results.multi_face_landmarks:
        for faceLms in face_results.multi_face_landmarks:
            center_x = int((faceLms.landmark[33].x + faceLms.landmark[263].x) * 0.5 * len(depth_image[0]))
            center_y = int((faceLms.landmark[33].y + faceLms.landmark[263].y) * 0.5 * len(depth_image))
            center_distance = depth_image[center_y, center_x] * depth_scale
            print(f"Face Center (x: {center_x}, y: {center_y}), Distance: {center_distance:.3f} meters")

    # Break the loop with a specific keypress fo

    key = cv2.waitKey(1)
    # Press esc or 'q' to exit the loop
    if key & 0xFF == ord('q') or key == 27:
        break

print(f"Application Closing")
pipeline.stop()
print(f"Application Closed.")
