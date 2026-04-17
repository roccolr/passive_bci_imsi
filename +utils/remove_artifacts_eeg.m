function output_path = remove_artifacts_eeg(input_path, fs)
% CLEAN_EEG_FILE Carica, pulisce e salva una matrice EEG Nx8.
%
%   INPUT:
%   - input_path: Stringa con il percorso completo o relativo del file .mat
%                 che contiene la matrice dei dati grezzi.
%   - fs:         (Opzionale) Frequenza di campionamento in Hz. Default: 250.
%
%   OUTPUT:
%   - output_path: Percorso in cui è stato salvato il nuovo file pulito.

    % 1. Gestione dei parametri di default
    if nargin < 2
        fs = 250; % Frequenza standard per Unicorn
    end

    % 2. Caricamento dei dati
    fprintf('Caricamento del file: %s\n', input_path);
    data_struct = load(input_path);
    
    % Estraiamo dinamicamente il nome della variabile salvata nel .mat
    var_names = fieldnames(data_struct);
    raw_data = data_struct.(var_names{1});
    
    % Controllo dimensioni: ci aspettiamo Nx8
    if size(raw_data, 2) ~= 8
        error('La matrice caricata non ha 8 colonne. Dimensioni rilevate: %dx%d', size(raw_data,1), size(raw_data,2));
    end
    
    cleaned_data = raw_data;
    
    % Filtro Passa-banda [1 - 40 Hz] (Rimozione derive lente e rumore HF)
    [b_bp, a_bp] = butter(4, [1, 40]/(fs/2), 'bandpass');
    cleaned_data = filtfilt(b_bp, a_bp, cleaned_data);

    %  Rimozione Artefatti Avanzata (ASR)
    
    try
        fprintf('Esecuzione ASR (EEGLAB) per rimozione blinks...\n');
        % ASR richiede i dati in formato (Canali x Campioni) -> Trasponiamo
        EEG_temp = pop_editset(eeg_emptyset, 'data', cleaned_data', 'srate', fs, 'nbchan', 8);

        % Esecuzione clean_artifacts 
        ASR = clean_artifacts(EEG_temp, 'WindowCriterion', 'off', 'chancorr_crit', 'off', 'line_crit', 'off');

        % Ripristiniamo il formato Nx8
        cleaned_data = double(ASR.data)';
    catch ME
        warning(['Rimozione ASR fallita (EEGLAB non trovato?). Uso solo filtri base. Dettaglio: ', ME.message]);
    end


    % Salvataggio nella nuova cartella
    % Estraiamo il percorso, il nome e l'estensione del file originale
    [filepath, name, ext] = fileparts(input_path);
    
    if isempty(filepath)
        filepath = pwd;
    end
    [parent_dir, ~, ~] = fileparts(filepath);
    new_folder = fullfile(parent_dir, 'Cleaned_Data');
    
    if ~exist(new_folder, 'dir')
        mkdir(new_folder);
    end
    output_path = fullfile(new_folder, [name, '_cleaned', ext]);
    eval([var_names{1} ' = cleaned_data;']);
    save(output_path, var_names{1});
    fprintf('Operazione conclusa. Dati puliti salvati in: %s\n', output_path);
end