import asyncio
import socket
import struct
from bleak import BleakScanner, BleakClient

# IMPOSTAZIONI BLUETOOTH
NOME_NUCLEO = "BlueNRG_SampleApp" 
UUID_RX_CHAR = "d973f2e2-b19e-11e2-9e96-0800200c9a66"

# IMPOSTAZIONI RETE SIMULINK
UDP_IP = "127.0.0.1"  

sock_passivo = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_passivo.bind((UDP_IP, 5011))
sock_passivo.setblocking(False) 

sock_attivo = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_attivo.bind((UDP_IP, 5010))
sock_attivo.setblocking(False) 

# SOGLIE DI SICUREZZA (Modificabili in qualsiasi momento)
SOGLIA_STANCHEZZA_MAX = 60.0       # Se la stanchezza SUPERA questo valore -> Blocco
SOGLIA_CONCENTRAZIONE_MIN = 20.0   # Se la concentrazione SCENDE SOTTO questo valore -> Blocco

# Variabili globali di stato
stanchezza = 0.0
concentrazione = 100.0  # Inizializzata a 100
stato_mano = 0
ultimo_mittente = "Nessuno"

# ASCOLTO BCI PASSIVO
async def ascolta_passivo():
    global stanchezza, concentrazione, ultimo_mittente
    while True:
        try:
            while True: 
                data, _ = sock_passivo.recvfrom(8192)
                valori = struct.unpack('<ff', data) 
                
                stanchezza = valori[0]
                concentrazione = valori[1]
                   
                ultimo_mittente = "PASSIVO"
        except BlockingIOError:
            pass 
        except Exception as e:
            print(f" ERRORE PASSIVO: {e}")
            
        await asyncio.sleep(0.01) 


# ASCOLTO BCI ATTIVO
async def ascolta_attivo():
    global stato_mano, ultimo_mittente
    while True:
        try:
            while True:
                data, _ = sock_attivo.recvfrom(8192)
                stato_mano = int(struct.unpack('B', data)[0])
                ultimo_mittente = "ATTIVO"
        except BlockingIOError:
            pass 
        except Exception as e:
            print(f" ERRORE ATTIVO: {e}")
            
        await asyncio.sleep(0.01)


# MAIN E LOGICA DI TRASMISSIONE BLUETOOTH
async def main():
    global stanchezza, concentrazione, stato_mano, ultimo_mittente

    # print(f" Cerco la scheda '{NOME_NUCLEO}'...")
    # devices = await BleakScanner.discover(timeout=20.0)
    # target_device = next((d for d in devices if d.name and NOME_NUCLEO in d.name), None)

    # if not target_device:
    #     print("\n Scheda non trovata.")
    #     return

    # print(f" Trovata: {target_device.name}. Connessione in corso...")
    # client = BleakClient(target_device)

    # for _ in range(5):
    #     try:
    #         await client.connect(timeout=10.0)
    #         break
    #     except Exception:
    #         await asyncio.sleep(2)

    # if not client.is_connected:
    #     print("\n Impossibile connettersi.")
    #     return

    # print("\n CONNESSIONE STABILITA! Avvio i motori asincroni...\n")

    task_act = asyncio.create_task(ascolta_passivo())
    task_pas = asyncio.create_task(ascolta_attivo())

    try:
        while True:
            # --- CALCOLO SICUREZZA (Doppia condizione) ---
            motivo_stato = ""
            
            if stanchezza >= SOGLIA_STANCHEZZA_MAX:
                b_blocco = 1
                motivo_stato = "🔴 BLOCCATO (Stanchezza Eccessiva)"
            elif concentrazione <= SOGLIA_CONCENTRAZIONE_MIN:
                b_blocco = 1
                motivo_stato = "🔴 BLOCCATO (Poca Concentrazione)"
            else:
                b_blocco = 0
                motivo_stato = "🟢 ATTIVO"

            # Formattazione e Invio allo schedino
            comando_str = f"B:{b_blocco},H:{stato_mano}\n"
            # await client.write_gatt_char(UUID_RX_CHAR, comando_str.encode('utf-8'))
            
            # Stampa di controllo
            if ultimo_mittente != "Nessuno":
                print(f" [{ultimo_mittente}] S:{stanchezza:>4.1f} | C:{concentrazione:>4.1f}  ->  Inviato: {comando_str.strip():<8} | {motivo_stato}")
                ultimo_mittente = "Nessuno" 
            
            await asyncio.sleep(0.25)
            
    except Exception as e:
        print(f"\n ❌ Errore BLE: {e}")
    finally:
        sock_passivo.shutdown(socket.SHUT_RDWR)
        sock_attivo.shutdown(socket.SHUT_RDWR)
        sock_passivo.close()
        sock_attivo.close()
        # if client.is_connected:
        #     await client.disconnect()

if __name__ == "__main__":
    asyncio.run(main())