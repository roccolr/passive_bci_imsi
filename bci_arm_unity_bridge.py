import asyncio
import socket
import struct
import json
from bleak import BleakScanner, BleakClient

# BLE connection parameters
ARM_DEVICE_NAME = "BlueNRG_SampleApp" 
ARM_SERVICE_UUID = "d973f2e2-b19e-11e2-9e96-0800200c9a66"

# Sockets-related parameters
LOCALHOST = "127.0.0.1"
PASSIVE_PORT = 5011
ACTIVE_PORT = 5010
UNITY_PORT = 5006

# Fatigue and concentration thresholds
FATIGUE_THRESHOLD = 60.0
CONCENTRATION_THRESHOLD = 20.0

# Sockets initialization
passive_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
passive_sock.bind((LOCALHOST, PASSIVE_PORT))
passive_sock.setblocking(False)

active_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
active_sock.bind((LOCALHOST, ACTIVE_PORT))
active_sock.setblocking(False)

unity_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Fatigue and concentration variables
fatigue = 0.0
concentration = 100.0

# Grip command sent to the end effector
grip_command = 0
# set to 0 to maintain the current end effector state
# set to 1 to switch the end effector state (open -> closed, or closed -> open)

# Safety flag for the robotic arm
hand_block = 0
# set to 0 when the arm is free to move (BCI metrics are normal)
# set to 1 when the arm has to be blocked due to fatigue or low concentration

latest_sender = "None"


async def passive_bci_handler():
    """
    Listens for passive BCI data incoming from the Simulink UDP socket.
    
    Unpacks the binary payload into float values representing fatigue 
    and concentration levels, updating the global state.
    """
    global fatigue, concentration, latest_sender
    while True:
        try:
            while True: 
                data, _ = passive_sock.recvfrom(8192)
                values = struct.unpack('<ff', data) 
                
                fatigue = values[0]
                concentration = values[1]
                latest_sender = "PASSIVE"
        except BlockingIOError:
            pass 
        except Exception as e:
            print(f"[passive_bci_handler] Error while trying to receive data: {e}")
            
        await asyncio.sleep(0.01) 


async def active_bci_handler():
    """
    Listens for active BCI data incoming from the Simulink UDP socket.
    
    Unpacks the binary payload into an integer value representing the active 
    motor imagery intent, updating the global grip command.
    """
    global grip_command, latest_sender
    while True:
        try:
            while True:
                data, _ = active_sock.recvfrom(8192)
                grip_command = struct.unpack('<B', data)[0]
                latest_sender = "ACTIVE"
        except BlockingIOError:
            pass
        except Exception as e:
            print(f"[active_bci_handler] Error while trying to receive data: {e}")
            
        await asyncio.sleep(0.01)


async def unity_handler():
    """
    Periodically transmits BCI metrics out to the Unity UDP socket.
    
    Serializes a JSON payload containing the latest rounded values 
    for fatigue and concentration.
    """    
    while True:
        try:
            bci_payload = {
                "type": "bci",
                "fatigue": round(fatigue, 2),
                "concentration": round(concentration, 2),
            }
            
            bci_payload_str = json.dumps(bci_payload) + "\n"
            unity_sock.sendto(bci_payload_str.encode('utf-8'), (LOCALHOST, UNITY_PORT))
            
        except Exception as e:
            print(f"[unity_handler] Error while trying to serialize or stream data: {e}")
            
        await asyncio.sleep(0.25)


async def arm_handler():
    """
    Handles discovery, connection lifecycle, safety evaluations, 
    and command transmission to the robotic arm with auto-reconnection.
    """
    global hand_block, latest_sender
    no_data_warning = False
    
    while True:
        try:
            print(f"Searching for '{ARM_DEVICE_NAME}'...")
            devices = await BleakScanner.discover(timeout=5.0)
            target_device = next((d for d in devices if d.name and ARM_DEVICE_NAME in d.name), None)

            if not target_device:
                print(f"Device '{ARM_DEVICE_NAME}' not found. Re-scanning in 3 seconds.")
                await asyncio.sleep(3)
                continue

            print(f"Device found: {target_device.name}. Setting up connection...")
            
            # Connection session tripwire flags
            disconnect_event = asyncio.Event()
            
            def on_disconnect(client):
                print(f"BLE connection with {ARM_DEVICE_NAME} is down.")
                disconnect_event.set()

            async with BleakClient(target_device, disconnected_callback=on_disconnect, timeout=15.0) as client:
                print(f"BLE connection established with device '{ARM_DEVICE_NAME}'.\n")

                while not disconnect_event.is_set():
                    # Evaluating fatigue and concentration
                    if fatigue >= FATIGUE_THRESHOLD or concentration <= CONCENTRATION_THRESHOLD:
                        hand_block = 1
                    else:
                        hand_block = 0

                    # Command string formatting and send to target device
                    command_str = f"B:{hand_block},G:{grip_command}\n"
                    await client.write_gatt_char(ARM_SERVICE_UUID, command_str.encode('utf-8'))

                    # Debug print of the received and evaluated data
                    if latest_sender != "None":
                        print(f"[{latest_sender}] F:{fatigue:>4.1f} | C:{concentration:>4.1f} -> Command sent: {command_str}")
                        latest_sender = "None"
                        no_data_warning = False
                    else:
                        if not no_data_warning:
                            print("No data received. Check if Simulink is running properly.")
                            no_data_warning = True

                    await asyncio.sleep(0.05)
                    
        except Exception as e:
            print(f"BLE error encountered: {e}")
            
        # Cooldown interval before resetting the loop to re-scan
        print("Initiating BLE connection cooldown before re-scanning...")
        await asyncio.sleep(2.0)


async def main():
    
    tasks = [
        asyncio.create_task(passive_bci_handler()),
        asyncio.create_task(active_bci_handler()),
        asyncio.create_task(unity_handler()),
        asyncio.create_task(arm_handler())
    ]
    
    try:
        await asyncio.gather(*tasks)
    finally:
        passive_sock.close()
        active_sock.close()
        unity_sock.close()


if __name__ == "__main__":
    asyncio.run(main())