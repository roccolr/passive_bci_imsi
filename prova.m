clear all
close all
clc


% Parametri

Fs = 1000;
t = 0:1/Fs:10;
ch =1:8;
run=4:9;
tmin=3;
tmax=6;

attento=1;
disattento=2;


%extraction












% % Preallocazione
% eeg_signal = zeros(n_channels, length(t));
% eeg_signal_with_noise = zeros(n_channels, length(t));
% eeg_signal_with_artifact = zeros(n_channels, length(t));
% 
% [signals, class, f_samp, run, ch, trials] = extraction(path, run, ch, trials, tmin,
% 
% % Frequenze (come prima, ma replicate)
% f1 = 10;
% f2 = 30;
% 
% noise_level = 0.1;
% artifact_intensity = 0.5;
% 
% for ch = 1:n_channels
% 
%     % Segnale EEG 
%     eeg_signal(ch,:) = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t);
% 
%     % Rumore 
%     eeg_signal_with_noise(ch,:) = eeg_signal(ch,:) + noise_level*randn(size(t));
% 
%     % Artefatto 
%     muscle_artifact = artifact_intensity*sin(2*pi*5*t);
% 
%     eeg_signal_with_artifact(ch,:) = eeg_signal_with_noise(ch,:) + muscle_artifact;
% end
% 
% 
% % Variabile finale per Simulink
% eeg_final = [t' eeg_signal_with_artifact'];
% 
% figure
% plot(t, eeg_signal_with_artifact');
