% setup

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
unicorn_f = 250 % hz
unicorn_buff_size = 25 % numero di campioni in un frame ricevuto da unicorn
amplitude_1 = 20e-6
amplitude_2 = 30e-6
amplitude_3 = 40e-6
amplitude_4 = 50e-6

calibration_duration = 60 % secondi
campioni_per_run = calibration_duration*unicorn_f



