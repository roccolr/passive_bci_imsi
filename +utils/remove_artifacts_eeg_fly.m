function cleaned_data = remove_artifacts_eeg_fly(data, fs)
% CLEAN_EEG_FILE pulisce una matrice EEG NxM.
%
%   INPUT:
%   - data: matrice N [campioni] x M [Canali]
%   - fs:         (Opzionale) Frequenza di campionamento in Hz. Default: 250.
%
%   OUTPUT:
%   - data_out: Matrice N x M ripulita.

    if nargin < 2
        fs = 250; % Frequenza standard per Unicorn
    end
    n_chan = size(data, 2);
    % Filtro Passa-banda [1 - 40 Hz] (Rimozione derive lente e rumore HF)
    [b_bp, a_bp] = butter(4, [1, 40]/(fs/2), 'bandpass');
    cleaned_data = filtfilt(b_bp, a_bp, data);

    %  Rimozione Artefatti Avanzata (ASR)
    
    try
        EEG_temp = pop_editset(eeg_emptyset, 'data', cleaned_data', 'srate', fs, 'nbchan', n_chan);
        ASR = clean_artifacts(EEG_temp, 'WindowCriterion', 'off', 'chancorr_crit', 'off', 'line_crit', 'off');
        cleaned_data = double(ASR.data)';
    catch ME
        warning(['Rimozione ASR fallita (EEGLAB non trovato?). Uso solo filtri base. Dettaglio: ', ME.message]);
    end

    
    

end