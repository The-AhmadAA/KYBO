import cv2

def normalize_coordinates(x, y, frame_width, frame_height):
    normalized_x = (x - frame_width / 2) / (frame_width / 2)
    normalized_y = (y - frame_height / 2) / (frame_height / 2)
    return normalized_x, normalized_y


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