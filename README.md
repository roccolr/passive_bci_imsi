# BCI department 
Repository for passive _BCI_ team.  

## Dependencies
DSP Toolbox <br>
statistics and machine learning toolbox
[EEGTOOLBOX](https://eeglab.org/tutorials/01_Install/Install.html) <br>
[CleanRawData](https://github.com/sccn/clean_rawdata) <br>


Per installare correttamente CleanRawData, eseguire il comando sulla console di matlab (lanciare matlab con i privilegi di amministratore):
```matlab
eeglab
```

Dalla GUI, selezionare file>manager estensioni e installare le seguenti estensioni:
1. clean_rawdata
2. bva-io
3. firfilt

## PIPELINE
-   Blocco che simula gli 8 segnali _sporchi_ (rumore e artefatti) provenienti da unicorn, ovvero un frame basato su 8 segnali campionati ad un data frequenza di campionamento 
-   Blocco di visualizzazione di questi 8 segnali e filtraggio 
-   Rimozione degli artefatti (funzione matlab)
-   Calcolo di eta theta ratio e engagement idx

## DIVISIONE LAVORO
