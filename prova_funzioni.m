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

%% Data Extraction & Saving
path = "./dataset/A02T";
raw_data_paths = {}; 
clean_data_paths = {};

% funzionalità da migliorare [] -> scartare i canali cattivi 
for i = 4:9
    signals = utils.extraction(path, i);
    [result, channels] = utils.check_signal(signals, 100, -100); % bisogna eliminare solo il segmento sporco di segnale
    
    if result == true
        fprintf("segnale buono...\n");
    else 
        for j = 1:length(channels)
            fprintf("segnali cattivi: %d\n", channels(j)); 
        end
    end 
    
    subFolder = 'vanilla_acquired_data';
    fileName = sprintf('dataset_sample_%s_run%d.mat', datestr(now, 'yyyy-mm-dd_HH-MM-SS'), i);
    
    if ~exist(subFolder, 'dir')
        mkdir(subFolder);
    end
    
    targetPath = fullfile(pwd, subFolder, fileName);
    save(targetPath, 'signals');
    raw_data_paths{end+1} = targetPath; % Append to cell array
end

%% Artifact Removal
for i = 1:length(raw_data_paths)
    % Passing character vector instead of string object
    clean_signals_path = utils.remove_artifacts_eeg(raw_data_paths{i}, 250);
    
    % Ensure load works correctly by specifying the expected variable
    loaded_data = load(clean_signals_path);
    clean_signals = loaded_data.signals;
    clean_data_paths{end+1} = clean_signals_path;
end

%% Feature Extraction
TBR_vector = [];
EI_vector = [];

for i = 1:length(clean_data_paths)
    [TBR_temp, EI_temp] = utils.retrieve_indexes(clean_data_paths{i}, 250, 2, 0.5);
    TBR_vector = [TBR_vector TBR_temp];
    EI_vector = [EI_vector EI_temp];
end 

TBR_mean_final = mean(TBR_vector);
EI_mean_final = mean(EI_vector);

%% Plotting
figure('Name', 'Indexes', 'Position', [100, 100, 800, 600]);

% Top plot
subplot(2, 1, 1); 
scatter(1:length(EI_vector), EI_vector, 'b');
grid on;
title('EI');
ylabel('EI');

% Bottom plot
subplot(2, 1, 2); 
scatter(1:length(TBR_vector), TBR_vector, 'r');
grid on;
title('TBR');
ylabel('TBR');

% Fixed variables and syntax
fprintf("[MAIN]\tTBR medio: %.3f\n", TBR_mean_final);
fprintf("[MAIN]\tEI medio: %.3f\n", EI_mean_final);

%%
