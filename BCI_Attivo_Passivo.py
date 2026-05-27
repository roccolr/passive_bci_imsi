import asyncio
import socket
import struct
from bleak import BleakScanner, BleakClient

# =====================================================================
# ⚙️ IMPOSTAZIONI BLUETOOTH (NUCLEO BRACCIO)
# =====================================================================
NOME_NUCLEO = "BlueNRG_SampleApp" 
UUID_RX_CHAR = "d973f2e2-b19e-11e2-9e96-0800200c9a66"

# =====================================================================
# 🌐 IMPOSTAZIONI RETE SIMULINK (DOPPIO ASCOLTO)
# =====================================================================
UDP_IP = "127.0.0.1"  

# 1. RICEVITORE BCI PASSIVO (Stanchezza + Intenzione)
PORTA_PASSIVO = 5006       
sock_passivo = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_passivo.bind((UDP_IP, PORTA_PASSIVO))
sock_passivo.setblocking(False) 

# 2. RICEVITORE BCI ATTIVO (Comando Diretto Mano a 8-bit)
PORTA_ATTIVO = 5010       
sock_attivo = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock_attivo.bind((UDP_IP, PORTA_ATTIVO))
sock_attivo.setblocking(False) 

# =====================================================================
# 🧠 PARAMETRI E SOGLIE
# =====================================================================
SOGLIA_STANCHEZZA = 60.0  

# =====================================================================
# 🚀 PROCESSO PRINCIPALE (IL PONTE UNIVERSALE)
# =====================================================================
async def main():
    print(f"🔍 Scansione BLE in corso per trovare '{NOME_NUCLEO}' (timeout 10s)...")
    
    devices = await BleakScanner.discover(timeout=10.0)
    target_device = next((d for d in devices if d.name and NOME_NUCLEO in d.name), None)

    if not target_device:
        print(f"\n❌ '{NOME_NUCLEO}' non trovata. Controlla accensione e spegni BT del telefono.")
        return

    print(f"\n✅ Trovata la scheda: {target_device.name} @ {target_device.address}")
    print(f"🔌 Avvio procedura di connessione...")

    connesso = False
    client = BleakClient(target_device)

    for tentativo in range(1, 6):
        try:
            print(f"🔌 Tentativo di connessione {tentativo}/5...")
            await client.connect(timeout=10.0)
            connesso = True
            break
        except Exception as e:
            print(f"⚠️ Tentativo fallito... riprovo. ({e})")
            await asyncio.sleep(2)

    if not connesso:
        print("\n❌ Impossibile connettersi.")
        return

    print("✅ CONNESSIONE STABILITA! Aspetto 2 secondi per il setup interno...\n")
    await asyncio.sleep(2.0)

    print("📡 Ponte UNIVERSALE Attivo!")
    print(f"   -> Ascolto BCI Passivo su porta UDP {PORTA_PASSIVO}")
    print(f"   -> Ascolto BCI Attivo  su porta UDP {PORTA_ATTIVO}\n")

    # Variabili di stato iniziali
    stanchezza = 0.0
    stato_mano = 0
    b_blocco = 0

    try:
        while True:
            # --- 1. LETTURA BCI PASSIVO (Porta 5006) ---
            # Se Simulink non invia il Passivo, questa parte viene semplicemente ignorata
            try:
                data_p, _ = sock_passivo.recvfrom(1024)
                valori = struct.unpack('<dd', data_p) # Legge due Double
                stanchezza = valori[0]
                
                # Se l'intenzione passiva scatta a 1, inverte la mano
                if int(valori[1]) == 1:
                    stato_mano = 1 if stato_mano == 0 else 0
            except BlockingIOError:
                pass # Nessun dato passivo arrivato, andiamo avanti
            except Exception:
                pass

            # --- 2. LETTURA BCI ATTIVO (Porta 5007) ---
            # Questo sovrascrive lo stato della mano con il dato diretto a 8-bit
            try:
                data_a, _ = sock_attivo.recvfrom(8192)
                comando_attivo = struct.unpack('B', data_a)[0] # Legge un uint8
                print(f"stato mano: {comando_attivo}")
            except BlockingIOError:
                pass # Nessun dato attivo arrivato, manteniamo lo stato precedente
            except Exception:
                pass

            # --- 3. CALCOLO LOGICA DI BLOCCO ---
            if stanchezza >= SOGLIA_STANCHEZZA:
                b_blocco = 1
                txt_sicurezza = "🔴 BLOCCATO (Stanco)"
            else:
                b_blocco = 0
                txt_sicurezza = "🟢 ATTIVO"

            # --- 4. FORMATTAZIONE E INVIO BLE ---
            comando_str = f"B:{b_blocco},H:{stato_mano}\n"
            comando_bytes = comando_str.encode('utf-8')
            
            await client.write_gatt_char(UUID_RX_CHAR, comando_bytes)
            
            # --- 5. LOG A SCHERMO ---
            print(f"🔄 DATI -> Stanchezza: {stanchezza:>4.1f} | Inviato a STM32: {comando_str.strip():<8} | {txt_sicurezza}")
            
            await asyncio.sleep(0.5)
            
    except Exception as e:
        print(f"\n❌ Errore/Disconnessione: {e}")
    finally:
        if client.is_connected:
            await client.disconnect()
            print("🔌 Disconnesso.")

if __name__ == "__main__":
    asyncio.run(main())