clc
clear
close all

function eeg_clean = remove_artifacts_eeg(eeg_in, fs)
% REMOVE_ARTIFACTS_EEG
% Rimuove artefatti da un segnale EEG multicanale.
%
% INPUT:
%   eeg_in : matrice [campioni x canali]
%   fs     : frequenza di campionamento
%
% OUTPUT:
%   eeg_clean : matrice [campioni x canali] filtrata
%
% Logica presa dalla funzione del prof (caso artif==5), adattata:
%   1) notch filter a 5 Hz per rimuovere l'artefatto che hai inserito
%   2) bandpass 1-40 Hz per mantenere la banda EEG utile

X = eeg_in;

% 1) Notch filter attorno a 5 Hz
[b_n, a_n] = butter(2, [4.5 5.5]/(fs/2), 'stop');
X = filtfilt(b_n, a_n, X);

% 2) Bandpass filter 1-40 Hz
[b, a] = butter(4, [1 40]/(fs/2), 'bandpass');
X = filtfilt(b, a, X);

eeg_clean = X;
end


% Parametri
fs = 250;               % frequenza di campionamento
T = 10;                 % durata del segnale in secondi
t = 0:1/fs:T-1/fs;      % vettore tempo

n_channels = 8;         % numero canali

f1 = 10;
f2 = 30;

noise_level = 0.1;
artifact_intensity = 0.5;

% Preallocazione
eeg_signal = zeros(n_channels, length(t));
eeg_signal_with_noise = zeros(n_channels, length(t));
eeg_signal_with_artifact = zeros(n_channels, length(t));

for ch = 1:n_channels

    % Segnale EEG base
    eeg_signal(ch,:) = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t);

    % Rumore
    eeg_signal_with_noise(ch,:) = eeg_signal(ch,:) + noise_level*randn(size(t));

    % Artefatto a 5 Hz
    muscle_artifact = artifact_intensity*sin(2*pi*5*t);

    % Segnale contaminato
    eeg_signal_with_artifact(ch,:) = eeg_signal_with_noise(ch,:) + muscle_artifact;
end

% Formato tempo x canali
eeg_data = eeg_signal_with_artifact';

% Rimozione artefatti con la nuova funzione
eeg_clean = remove_artifacts_eeg(eeg_data, fs);

% Variabili finali per Simulink
eeg_final = [t' eeg_data];
eeg_final_clean = [t' eeg_clean];

% Grafico confronto sul canale 1
figure
plot(t, eeg_data(:,1), 'r')
hold on
plot(t, eeg_clean(:,1), 'b')
xlabel('Tempo (s)')
ylabel('Ampiezza')
title('Confronto segnale contaminato vs filtrato - Canale 1')
legend('Con artefatto', 'Filtrato')
grid onclc
clear
close all

% Parametri
fs = 250;               % frequenza di campionamento
T = 10;                 % durata del segnale in secondi
t = 0:1/fs:T-1/fs;      % vettore tempo

n_channels = 8;         % numero canali

f1 = 10;
f2 = 30;

noise_level = 0.1;
artifact_intensity = 0.5;

% Preallocazione
eeg_signal = zeros(n_channels, length(t));
eeg_signal_with_noise = zeros(n_channels, length(t));
eeg_signal_with_artifact = zeros(n_channels, length(t));

for ch = 1:n_channels

    % Segnale EEG base
    eeg_signal(ch,:) = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t);

    % Rumore
    eeg_signal_with_noise(ch,:) = eeg_signal(ch,:) + noise_level*randn(size(t));

    % Artefatto a 5 Hz
    muscle_artifact = artifact_intensity*sin(2*pi*5*t);

    % Segnale contaminato
    eeg_signal_with_artifact(ch,:) = eeg_signal_with_noise(ch,:) + muscle_artifact;
end

% Formato tempo x canali
eeg_data = eeg_signal_with_artifact';

% Rimozione artefatti con la nuova funzione
eeg_clean = remove_artifacts_eeg(eeg_data, fs);

% Variabili finali per Simulink
eeg_final = [t' eeg_data];
eeg_final_clean = [t' eeg_clean];

% Grafico confronto sul canale 1
figure
plot(t, eeg_data(:,1), 'r')
hold on
plot(t, eeg_clean(:,1), 'b')
xlabel('Tempo (s)')
ylabel('Ampiezza')
title('Confronto segnale contaminato vs filtrato - Canale 1')
legend('Con artefatto', 'Filtrato')
grid on