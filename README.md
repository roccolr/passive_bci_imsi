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
bci_passivo
├── +utils
│   ├── check_signal.m
│   ├── clean_artifacts (1).m
│   ├── compare_data.m
│   ├── data_mine.m
│   ├── extraction.m
│   ├── remove_artifacts_eeg.m
│   ├── remove_artifacts_eeg_fly.m
│   ├── retrieve_indexes.m
│   └── retrieve_indexes_fly.m
├── LICENSE
├── README.md
├── cleaned_data
├── dataset
│   ├── A01T.mat
│   ├── A02T.mat
│   ├── A03T.mat
│   ├── A05T.mat
│   ├── A06T.mat
│   ├── A07T.mat
│   ├── A08T.mat
│   └── A09T.mat
├── install
│   └── instruction.md
├── setup.m
├── test_scenario.slx
├── vanilla_acquired_data
└── various_scripts
    └── prova_funzioni.m
```