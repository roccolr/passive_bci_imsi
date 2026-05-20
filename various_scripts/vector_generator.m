clc
clear
close all

try
    eeglab nogui;
catch
    error('Assicurati che la cartella principale di EEGLAB sia nel path di MATLAB.');
end

eeglab_base_path = fileparts(which('eeglab'));
addpath(genpath(fullfile(eeglab_base_path, 'plugins')));

%%
clean_data_paths = {};
folder_path = 'C:\Users\IRISc\passive_bci_imsi\custom_dataset_mat\';
file_pattern = fullfile(folder_path, '*.mat');
files = dir(file_pattern);
output_folder = './vector_data/EI';
 % canali interessanti : [1 3 5]

for i = 1:length(files)
    if files(i).isdir
        continue;
    end

    % Estrai nome del file e percorso completo
    filename = files(i).name;
    full_path = fullfile(folder_path, filename);
    
    % --- INSERISCI QUI LE OPERAZIONI DA ESEGUIRE ---
    fprintf('Elaborazione di: %s\n', full_path);
    
    data = load(full_path).data;
    clean_signals_path = utils.remove_artifacts_eeg(full_path, 250);
    
    [TBR, EI] = utils.retrieve_indexes_custom(full_path, 250, 2, 0.5);
    [~, base_name, ~] = fileparts(filename);
    output_filename = [base_name, '.csv'];
    output_full_path = fullfile(output_folder, output_filename);

    writematrix(EI, output_full_path);
    fprintf('Matrice esportata in: %s\n', full_path);
end


