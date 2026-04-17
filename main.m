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

% --- PARAMETRI DI SIMULAZIONE UNICORN ---

%% 
unicorn_f = 250 % hz
unicorn_buff_size = 25 % numero di campioni in un frame ricevuto da unicorn
amplitude_1 = 20e-6
amplitude_2 = 30e-6
amplitude_3 = 40e-6
amplitude_4 = 50e-6

calibration_duration = 60 % secondi
campioni_per_run = calibration_duration*unicorn_f
%% 

% --- SALVATAGGIO DATI ---
subFolder = 'vanilla_acquired_data';
fileName = ['EEG_calibration_session_', datestr(now, 'yyyy-mm-dd_HH-MM'), '.mat'];
if ~exist(subFolder, 'dir')
    mkdir(subFolder);
end

eeg_filtered_data = out.eeg_fitlered_data;
targetPath = fullfile(pwd, subFolder, fileName);
save(targetPath, 'eeg_filtered_data');
fprintf('Dati salvati correttamente in: %s\n', targetPath);

%% 

% --- ELABORAZIONE DATI ---
eeg_without_artifacts = utils.remove_artifacts_eeg(targetPath, unicorn_f);

%% 

% --- STAMPA E COMPARAZIONE --- 
dirty_path = 'vanilla_acquired_data\EEG_calibration_session_2026-04-17_13-07.mat';
cleaned_path = 'cleaned_data\EEG_calibration_session_2026-04-17_13-07_cleaned.mat';

compare_data(dirty_path, cleaned_path);