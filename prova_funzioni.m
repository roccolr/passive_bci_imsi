clc
clear
close all

try
    eeglab nogui;
catch
    error('Assicurati che la cartella principale di EEGLAB sia nel path di MATLAB.');
end

%% 

path = "./dataset/A01T";
signals = utils.extraction(path);
result = utils.check_signal(signals, 100e-6, -100e-6);

if result == true
    fprintf("segnale buono...\n")
else 
    fprintf("segnale cattivo...\n")
end 

subFolder = 'vanilla_acquired_data';
fileName = ['dataset_sample_', datestr(now, 'yyyy-mm-dd_HH-MM'), '.mat'];
if ~exist(subFolder, 'dir')
    mkdir(subFolder);
end
targetPath = fullfile(pwd, subFolder, fileName);
save(targetPath, 'signals');

%%
raw_data_fig = figure('Name', 'Raw Data', 'Position', [100, 100, 1000, 800]);

for i = 1:8
    % subplot(numero_righe, numero_colonne, indice_grafico)
    subplot(4, 2, i);
    plot(signals(:, i));
    title(sprintf('Segnale %d', i));
    grid on;
end
pause(3);
close(raw_data_fig);

%%

clean_signals_path = utils.remove_artifacts_eeg(targetPath, 250);
clean_signals = load(clean_signals_path).signals;
%%

clean_data_fig = figure('Name', 'Cleaned Data', 'Position', [100, 100, 1000, 800]);

for i = 1:8
    % subplot(numero_righe, numero_colonne, indice_grafico)
    subplot(4, 2, i);
    plot(clean_signals(:, i));
    title(sprintf('Segnale %d', i));
    grid on;
end

%%
utils.compare_data(targetPath, clean_signals_path);