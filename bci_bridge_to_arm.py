import asyncio
import socket
import struct
from bleak import BleakScanner, BleakClient

# BLE connection parameters
DEVICE_NAME = "BlueNRG_SampleApp" 
SERVICE_UUID = "d973f2e2-b19e-11e2-9e96-0800200c9a66"

# Fatigue and concentration thresholds
FATIGUE_THRESHOLD = 60.0
CONCENTRATION_THRESHOLD = 20.0

# Simulink connection parameters
LOCALHOST = "127.0.0.1"
PASSIVE_PORT = 5011
ACTIVE_PORT = 5010

# Simulink connection variables
passive_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
passive_sock.bind((LOCALHOST, PASSIVE_PORT))
passive_sock.setblocking(False)

active_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
active_sock.bind((LOCALHOST, ACTIVE_PORT))
active_sock.setblocking(False)

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

async def passive_bci():
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
            print(f"Passive BCI receiving error: {e}")
            
        await asyncio.sleep(0.01) 


# ASCOLTO BCI ATTIVO
async def active_bci():
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
            print(f"Active BCI receiving error: {e}")
            
        await asyncio.sleep(0.01)

async def main():
    global fatigue, concentration, grip_command, latest_sender

    print(f"Searching for '{DEVICE_NAME}'...")
    devices = await BleakScanner.discover(timeout=20.0)
    target_device = next((d for d in devices if d.name and DEVICE_NAME in d.name), None)

    if not target_device:
        print("\nDevice not found.")
        return

    print(f"Device found: {target_device.name}. Setting up connection...")
    client = BleakClient(target_device)

    for _ in range(5):
        try:
            await client.connect(timeout=10.0)
            break
        except Exception:
            await asyncio.sleep(1)

    if not client.is_connected:
        print("\nConnection failed.")
        return

    print(f"\nConnection estabilished with device '{DEVICE_NAME}'.\n")

    passive_task = asyncio.create_task(passive_bci())
    active_task = asyncio.create_task(active_bci())

    try:
        while True:
            # Evaluating fatigue and concentration
            if fatigue >= FATIGUE_THRESHOLD or concentration <= CONCENTRATION_THRESHOLD:
                hand_block = 1
            else:
                hand_block = 0

            # Command string formatting and send to target device
            command_str = f"B:{hand_block},G:{grip_command}\n"
            await client.write_gatt_char(SERVICE_UUID, command_str.encode('utf-8'))

            # Debug print of the received and evaluated data
            if latest_sender != "None":
                print(f"[{latest_sender}] F:{fatigue:>4.1f} | C:{concentration:>4.1f} -> Command sent: {command_str}")
            else:
                print("No data received yet.")
            
            await asyncio.sleep(0.25)
            
    except Exception as e:
        print(f"\nBLE connection error: {e}")
    finally:
        passive_sock.shutdown(socket.SHUT_RDWR)
        active_sock.shutdown(socket.SHUT_RDWR)
        passive_sock.close()
        active_sock.close()
        if client.is_connected:
            await client.disconnect()

if __name__ == "__main__":
    asyncio.run(main())