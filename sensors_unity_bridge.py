import asyncio
import socket
import struct
import json
from bleak import BleakScanner, BleakClient

# Unity connection parameters
LOCALHOST = "127.0.0.1"
UNITY_PORT = 5005

# BLE connection parameters
SENSORS_DEVICE_NAME = "BlueNRG"
SENSORS_SERVICE_UUID = "f0debc9a-7856-3412-7856-341278563412"

unity_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Global sensor telemetry variables
temperature = 0.0
pressure    = 0.0
humidity    = 0.0
vibrations  = 0.0
security    = True


def handle_data(sender, data):
    """
    Asynchronously triggered whenever the BlueNRG peripheral emits data.
    Unpacks raw C memory and commits it to the global state.
    """
    global temperature, pressure, humidity, vibrations, security, z_ax
    data_length = len(data)
    
    if data_length == 44:
        try:
            # Unpack the Little-Endian C Struct payload
            values = struct.unpack('<If4Bifi3fB3xB3x', data)
            
            vibrations = values[7] # this one actually represents vibrations along z-axis
            humidity = values[9]
            temperature = values[10]
            pressure = values[11]
            # vibrations = values[12] this one is a flag to know if vibrations reach a specific threshold
            security = True if values[13] == 1 else False

        except Exception as e:
            print(f"[handle_data] Error while decoding data: {e}")
    else:
        print("[handle_data] The received packet is corrupted.")


async def sensor_ble_handler():
    """
    Handles discovery, notification subscriptions, and connection lifecycles 
    for the Environmental Sensor board with automated auto-reconnection.
    """
    while True:
        try:
            print(f"Searching for '{SENSORS_DEVICE_NAME}'...")
            devices = await BleakScanner.discover(timeout=5.0)
            target_device = next((d for d in devices if d.name and SENSORS_DEVICE_NAME in d.name), None)

            if not target_device:
                print(f"Device '{SENSORS_DEVICE_NAME}' not found. Re-scanning in 5 seconds...")
                await asyncio.sleep(5)
                continue

            print(f"Device found: {target_device.name}. Setting up connection...")
            
            disconnect_event = asyncio.Event()
            
            def on_disconnect(client):
                print(f"BLE connection with {SENSORS_DEVICE_NAME} is down.")
                disconnect_event.set()

            async with BleakClient(target_device, disconnected_callback=on_disconnect, timeout=10.0) as client:
                print(f"BLE connection established with device '{SENSORS_DEVICE_NAME}'.\n")
                
                # Subscribe to the background data notification stream
                await client.start_notify(SENSORS_SERVICE_UUID, handle_data)
                
                # Suspend this specific task loop cleanly until the OS triggers the drop callback
                await disconnect_event.wait()
                
        except Exception as e:
            print(f"BLE error encountered: {e}")
            
        # 3.5 second staggered cooldown interval to prevent hardware driver resource contention
        print("Initiating BLE connection cooldown before re-scanning...")
        await asyncio.sleep(3.5)


async def unity_handler():
    """
    Periodically transmits sensor telemetry out to the Unity UDP socket.
    
    Serializes a JSON payload containing the latest ambient metrics 
    and pushes it directly to the game engine.
    """
    while True:
        try:
            unity_data = {
                "type": "telemetry",
                "temperature": round(temperature, 2),
                "press": round(pressure, 2),
                "humidity": round(humidity, 2),
                "vibrations": round(vibrations, 2),
                "security": security
            }
            print(f"Streaming data to Unity: {unity_data}")
            payload_str = json.dumps(unity_data) + "\n"
            unity_sock.sendto(payload_str.encode('utf-8'), (LOCALHOST, UNITY_PORT))
            
        except Exception as e:
            print(f"[unity_handler] Error while trying to serialize or stream data: {e}")
            
        await asyncio.sleep(0.05)


async def main():
    
    tasks = [
        asyncio.create_task(sensor_ble_handler()),
        asyncio.create_task(unity_handler())
    ]
    
    try:
        await asyncio.gather(*tasks)
    finally:
        unity_sock.close()


if __name__ == "__main__":
    asyncio.run(main())