import cv2, argparse

def normalize_coordinates(x, y, frame_width, frame_height):
    normalized_x = (x - frame_width / 2) / (frame_width / 2)
    normalized_y = (y - frame_height / 2) / (frame_height / 2)
    return normalized_x, normalized_y

def get_bounding_box(bodyLms):
    x_coords = [landmark.x for landmark in bodyLms.landmark]
    y_coords = [landmark.y for landmark in bodyLms.landmark]
    return min(x_coords), min(y_coords), max(x_coords), max(y_coords)

def average_boxes(boxes):
    avg_min_x = sum([box[0] for box in boxes]) / len(boxes)
    avg_min_y = sum([box[1] for box in boxes]) / len(boxes)
    avg_max_x = sum([box[2] for box in boxes]) / len(boxes)
    avg_max_y = sum([box[3] for box in boxes]) / len(boxes)
    return avg_min_x, avg_min_y, avg_max_x, avg_max_y

def get_center_of_box(min_x, min_y, max_x, max_y):
    center_x = min_x + (max_x - min_x) / 2
    center_y = min_y + (max_y - min_y) / 2
    return center_x, center_y


def calculate_box_area(min_x, min_y, max_x, max_y):
    area = (max_x - min_x) * (max_y - min_y)
    return area

def get_overlap(boxA, boxB):
    xA = max(boxA[0], boxB[0])
    yA = max(boxA[1], boxB[1])
    xB = min(boxA[2], boxB[2])
    yB = min(boxA[3], boxB[3])

    # Check if there's no intersection
    if xA >= xB or yA >= yB:
        return 0

    # Compute the area of intersection
    interArea = (xB - xA) * (yB - yA)
    return interArea


def calculate_hand_centroid(handLms):
    x = sum([lm.x for lm in handLms.landmark]) / len(handLms.landmark)
    y = sum([lm.y for lm in handLms.landmark]) / len(handLms.landmark)
    return x, y

def cleanup(server, realsense=None, camera=None):
    print("Cleaning up...")
    try:
        server.close()
        if realsense != None:
            realsense.stop()
        if camera != None:
            camera.release()
            cv2.destroyAllWindows()
    except:
        pass
    print("Cleanup completed!")

def parse_args():
    parser = argparse.ArgumentParser(description="Detection")
    parser.add_argument('--display', action='store_true', help="Display the OpenCV window with drawings")
    parser.add_argument('--noserver', action='store_true', help="Run the Python script without starting the server")
    return parser.parse_args()

def normalize_display_box(frame, box, width, height, color):
        start_x = width - int(box[2] * width)
        end_x = width - int(box[0] * width)
        start_y = int(box[1] * height)
        end_y = int(box[3] * height)

        cv2.rectangle(frame, (start_x, start_y), (end_x, end_y), color, 2)
