import pyrealsense2 as rs
import mediapipe as mp
import socket

class Server:
    def __init__(self, address='127.0.0.1', port=65445):
        self.address = address
        self.port = port
        self.conn = None
        self.server_socket = None

    def start(self):
        self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.server_socket.bind((self.address, self.port))
        self.server_socket.listen()

        print("Waiting for connection...")
        self.conn, addr = self.server_socket.accept()

    def send_data(self, data):
        self.conn.sendall(data)

    def close(self):
        self.conn.close()
        self.server_socket.close()

class Realsense:
    def __init__(self, resolution=(640, 480), fps=30):
        self.resolution = resolution
        self.fpgs = fps
        self.pipeline = rs.pipeline()
        self.align = rs.align(rs.stream.color)

    def setup(self):
        ctx =  rs.context()
        connected_devices = [ctx.devices[i].get_info(rs.camera_info.serial_number) for i in range(len(ctx.devices))]
        device = connected_devices[0]
        config = rs.config()

        config.enable_device(self.device)
        config.enable_stream(rs.stream.depth, *self.resolution, rs.format.z16, self.fpgs)
        config.enable_stream(rs.stream.color, *self.resolution, rs.format.bgr8, self.fpgs)
        profile = self.pipeline.start(config)
        self.align = rs.align(rs.stream.color)
        self.depth_scale = self.profile.get_device().first_depth_sensor().get_depth_scale()

    def get_frames(self):
        frames = self.pipeline.wait_for_frames()
        return self.align.process(frames)

    def stop(self):
        self.pipeline.stop()

class MediaPipeProcessor:
    def __init__(self):
        self.hands = mp.solutions.hands.Hands()
        self.face = mp.solutions.face_mesh.FaceMesh()

    def process_hands(self, image):
        return self.hands.process(image)

    def process_face(self, image):
        return self.face.process(image)