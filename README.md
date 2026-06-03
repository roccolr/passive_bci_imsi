# BCI department 
Repository for passive _BCI_ team.  

## Dependencies
DSP Toolbox <br>
statistics and machine learning toolbox <br>
[EEGLAB](https://drive.google.com/drive/folders/1PAmuaPlNM6usjKqu5bbb7TdUnteIZf5i) <br>
[CleanRawData](https://github.com/sccn/clean_rawdata) <br>


Per installare correttamente CleanRawData, eseguire il comando sulla console di matlab (lanciare matlab con i privilegi di amministratore):
```matlab
eeglab
```
Dalla GUI, selezionare file>manager estensioni e installare le seguenti estensioni:
1. clean_rawdata
2. bva-io
3. firfilt

##Nota
Nella versione legacy non è necessario installare altre dipendenze per EEGLAB. Aggiungere EEGLAB al path (avendo cura di non includere le sotto directories) attraverso il comando: 
```matlab
pathtool
```

## PIPELINE
-   Eseguire il file setup.m
-   Eseguire il modello simulink 

input: 8 segnali eeg 
output: bool arresto 

## Project tree

```
project
├── aBCI_CalibrationSimulation.slxc
├── bci_arm_unity_bridge.py
├── bci_bridge_to_arm.py
├── BCI_Control_Log_2024a.slx
├── BCI_Control_Log_2024a.slx.original
├── bci.slx
├── best_interval.mat
├── data_analysis
│   ├── main.py
│   ├── python_lib
│   │   ├── scatter_with_regression.py
│   │   ├── sean.py
│   │   ├── tempCodeRunnerFile.py
│   │   ├── transformer.py
│   │   └── trend_extractor.py
│   └── requirements.txt
├── FUNCTIONS
│   ├── boundedline.m
│   ├── CSP_2task.m
│   ├── CSPapply.m
│   ├── CSPtrain.m
│   ├── extraction.m
│   ├── filterBankCOYLE.m
│   ├── inpaint_nans.m
│   ├── inputsdlg.m
│   └── separation.m
├── install
│   └── instruction.md
├── LICENSE
├── OfflineDataAnalysis_Unicorn.m
├── profilazione_legacy.slx
├── profilazione.m
├── profilazione.slx
├── README.md
├── RunTime.m
├── SaveData.m
├── setup.m
├── test_scenario_legacy.slx
├── test_scenario.slx
├── test_scenario.slxc
├── +utils
│   ├── check_signal.m
│   ├── compare_data.m
│   ├── data_mine.m
│   ├── extraction.m
│   ├── process_data.m
│   ├── remove_artifacts_eeg_fly.m
│   ├── remove_artifacts_eeg.m
│   ├── retrieve_indexes_custom.m
│   ├── retrieve_indexes_fly.m
│   └── retrieve_indexes.m
└── various_scripts
    ├── prova_funzioni.m
    └── vector_generator.m
```

## Python requirements 
Crea un virtual environment 

```bash
python3 -m venv myvenv
```

Usa pip di questo environment per installare le dipendenze:

```matlab
pip3 install -r data_analysis/requirements.txt
```

## Istruzioni per acquisizioni di AlfaAlfa
1. Aprire su simulink il file /profilazione.slcx;
2. Aprire su matlab il file /profilazione.m;
3. Eseguire la sezione denominata SETUP su matlab; 
4. Eseguire la sezione denominata VARIABLES su matlab;
5. Creare, se non esiste già, nella cartella principale del progetto la cartella "dataset_alfo";
6. Nella sezione acquisizione, cambiare la variabile numero_osservazione = i con i=1...30;
7. Eseguire l'acquisizione su simulink, assicurandosi che il tempo sia settato a 60 s;
8. Dopo la 30esima iterazione, avviare su matlab la sezione data_process. 

L'output dell'ultimo passaggio dovrebbe essere:
```bash
[MAIN]	MEDIA TBR: 	0.843	CL 99.0		CI [0.5974, 1.0886] dev [0.4880]
[MAIN]	MEDIA EI: 	0.308	CL 99.0		CI [0.2149, 0.4016] dev [0.1856]
```

## Note per l'integrazione 
1. Discutere circa l'utilizzo dello stesso blocco per la rimozione degli artefatti;
