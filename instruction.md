import os

content = """# Guida Operativa BCI - Unicorn Suite & Unity
**Ultimo aggiornamento:** 01/04/2025

Questo documento descrive i prerequisiti, la fase di calibrazione e la fase di evaluation per l'utilizzo dell'app BCI con Unicorn Suite, Matlab e Unity.

---

## PREREQUISITI

Il PC in uso deve avere i seguenti software installati:

* **Unity Hub** (Gratuito) - Versione utilizzata: `2022.3.16f1`.
* **Matlab 2024a** (Licenza UNINA).
* **Unicorn Suite** (File eseguibile su Teams: `Self-paced BCI (Galasso) > Unicorn > Unicorn black Suite`).
    * *Nota:* Utilizzare sempre l'ultima release per la gestione delle licenze.
    * *Aggiornamenti:* Aprire e aggiornare tramite l'icona a destra:
        * `Unicorn Suite > Apps > Unicorn Recorder`
        * `Unicorn Suite > Dev Tools > Unicorn Simulink`

### Configurazione Path Matlab
Aggiungere al path di Matlab la cartella `UnicornLib`:
`Matlab > Set Path > C:\\Users\\<username>\\Documents\\gtec\\Unicorn Suite\\Hybrid Black\\Unicorn Simulink\\Lib`

---

## FASE DI CALIBRAZIONE

**Protocollo:** [2 run da 45 trial ciascuno] + trial iniziali di prova (non salvati).

1.  **Preparazione:**
    * Montare il cap sul soggetto.
    * Inserire l'USB del cap.
    * Verificare la qualità del segnale su **Unicorn Suite**.

2.  **Esecuzione:**
    * Avviare `aBCI_CalibrationScript.m` (Percorso ASUS: `Desktop > BCI ATTIVO > 1_Calibration`).
    * Eseguire la **prima sezione** dello script e inserire i dati richiesti.
    * Aprire l'app Unity di calibrazione: `Calibration_app.exe` (Percorso ASUS: `Desktop > BCI ATTIVO > Unity`).
    * Aprire e avviare il modello Simulink: `aBCI_CalibrationSimulation.slx` (Percorso ASUS: `Desktop > BCI ATTIVO > 1_Calibration`).
    * Tornare sull'app Unity `Calibration_app.exe`, inserire il numero di trials e cliccare **Start** (`Alt+Enter` per schermo intero).
    * Al termine del run, tornare su `aBCI_CalibrationScript.m` ed eseguire la sezione rimanente per il salvataggio dei dati.

### Processing Offline
1.  Avviare `OfflineDataAnalysis_Unicorn.m` (Percorso ASUS: `Desktop > BCI ATTIVO > 2_OfflineDataAnalysis&Evaluation`).
2.  Eseguire la prima sezione di `experimentalProtocol_Unicorn.m` e inserire i risultati ottenuti da `OfflineDataAnalysis_Unicorn.m`.

---

## FASE DI EVALUATION

1.  **Apertura App Unity:**
    Scegliere l'app corretta in base al livello (Percorso ASUS: `Desktop > BCI ATTIVO > Unity`):
    * `Evaluation_App_V2.exe` (Tutti i 3 livelli)
    * `Evaluation_App_LVL1.exe` (Livello 1)
    * `Evaluation_App_LVL2.exe` (Livello 2)
    * `Evaluation_App_LVL3.exe` (Livello 3)

2.  **Configurazione Simulink:**
    * Avviare lo schema Simulink `Modello_evaluation_Unicorn_NEW.slx` (Percorso ASUS: `Desktop > BCI ATTIVO > Unity`).
    * *Nota:* Assicurarsi che il path su Matlab comprenda i sottosistemi delle funzioni utilizzate da Simulink.

3.  **Esecuzione:**
    * Cliccare **Play** sull'app Unity.
    * Al termine dei tentativi di gioco online, cliccare su **END SESSION**.
    * Eseguire l'ultima sezione di `experimentalProtocol_Unicorn.m` per il salvataggio dei dati `EvData`.
"""

file_path = "README.md"
with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)