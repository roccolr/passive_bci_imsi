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

###Nota
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
passive_bci_imsi/
├── +utils
│   ├── check_signal.m
│   ├── clean_artifacts (1).m
│   ├── compare_data.m
│   ├── data_mine.m
│   ├── extraction.m
│   ├── remove_artifacts_eeg.m
│   ├── remove_artifacts_eeg_fly.m
│   ├── retrieve_indexes.m
│   ├── retrieve_indexes_custom.m
│   └── retrieve_indexes_fly.m
├── LICENSE
├── README.md
├── data_analysis
│   ├── bci_analysis
│   ├── main.py
│   ├── python_lib
│   └── requirements.txt
├── install
│   └── instruction.md
├── setup.m
├── slprj
│   ├── _consts
│   ├── _jitprj
│   ├── _sfprj
│   └── sim
├── test_scenario.slx
├── test_scenario.slxc
├── test_scenario_legacy.slx
├── vanilla_acquired_data
├── various_scripts
│   ├── prova_funzioni.m
│   ├── vector_generator.asv
│   └── vector_generator.m
└── vector_data
    ├── EI
    └── TBR
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

