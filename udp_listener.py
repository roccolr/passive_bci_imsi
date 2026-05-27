import socket
import struct
ip = "127.0.0.1"
port = 5010
buffer_size = 8192

def start_listener():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((ip, port))
    print("bind successful")
    try:
        while True:
            data, addr = sock.recvfrom(buffer_size)
            message = struct.unpack("B", data)[0]
            print(message)
    except KeyboardInterrupt:
        print("keyboard int")
    except socket.timeout:
        print("socket is timing out")
    finally:
        sock.close()

if __name__ == "__main__":
    start_listener()