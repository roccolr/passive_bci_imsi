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
dirty_path = "/home/jsorel/Desktop/passive_bci_imsi/vanilla_acquired_data/EEG_calibration_session_2026-04-23_11-19.mat"
cleaned_path = "/home/jsorel/Desktop/passive_bci_imsi/cleaned_data/EEG_calibration_session_2026-04-23_11-19_cleaned.mat"

utils.compare_data(dirty_path, cleaned_path);

%%
% --- ESTRAZIONE BANDA ---

eeg_without_artifacts_data = load(cleaned_path);
eeg_without_artifacts_data = eeg_without_artifacts_data.eeg_filtered_data;
win_sec = 2; % ampiezza temporale finestra
win_len = round(win_sec*unicorn_f);
overlap = 0.5; % intervallo sovrapposizione 
step = round(win_len * (1-overlap));

[N, nCh] = size(eeg_without_artifacts_data);
num_win = floor((N-win_len)/step) +1;


[b_theta, a_theta] = butter(4, [4 8]/(unicorn_f/2), 'bandpass'); 
[b_alpha, a_alpha] = butter(4, [8 13]/(unicorn_f/2), 'bandpass'); 
[b_beta, a_beta] = butter(4, [13 30]/(unicorn_f/2), 'bandpass'); 

pow_theta = zeros(nCh, num_win);
pow_alpha = zeros(nCh, num_win);
pow_beta = zeros(nCh, num_win);


TBR = zeros(nCh, num_win);
EI = zeros(nCh, num_win);

tim_vec = zeros(num_win, 1);
eps_value = 1e-8;

for ch = 1:nCh 
    x = eeg_without_artifacts_data(:, ch);
    for i = 1:num_win 
        idx_start = (i-1)*step + 1;
        idx_end = idx_start + win_len -1;

        segment = x(idx_start:idx_end, :);

        theta = filtfilt(b_theta, a_theta, segment);
        beta = filtfilt(b_beta, a_beta, segment);
        alpha = filtfilt(b_alpha, a_alpha, segment);


        pow_theta(ch,i) = var(theta);
        pow_beta(ch,i) = var(beta);
        pow_alpha(ch,i) = var(alpha);

        TBR(ch,i) = pow_theta(ch, i) / (pow_beta(ch,i) + eps_value);
        EI(ch,i) = pow_beta(ch, i) / (pow_alpha(ch,i) + pow_theta(ch,i)+eps_value);

        if ch==1
            tim_vec(i) = (idx_start+idx_end)/(2*unicorn_f);
        end 
    end
end

TBR_mean = mean(TBR, 1);
EI_mean = mean(EI, 1);

TBR_value = median(TBR_mean);
EI_value = median(EI_mean);

fprintf("[MAIN]\tTBR mediano: %.3f\n", TBR_value);
fprintf("[MAIN]\tEI mediano: %.3f\n", EI_value);

