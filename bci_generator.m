clear all
close all
clc

%Generate EEG signal with noise and artifacts
Fs = 1000; % Sampling frequency
% t = 0:1/Fs:1-1/Fs; % Time vector
t = 0:1/Fs:10; % Time vector
% Simulated EEG signal with multiple frequencies and noise
f1 = 10; % Frequency of the primary EEG signal in Hz
f2 = 30; % Frequency of an additional EEG signal component in Hz
eeg_signal = sin(2*pi*f1*t) + 0.5*sin(2*pi*f2*t); % Simulated EEG signal with two frequency components
% Add Gaussian noise to the EEG signal
noise_level = 0.1; % Adjust noise level as needed
eeg_signal_with_noise = eeg_signal + noise_level*randn(size(t));
% Simulate muscle artifact
artifact_intensity = 0.5; % Adjust artifact intensity as needed
muscle_artifact = artifact_intensity*sin(2*pi*5*t); % Muscle artifact at 5 Hz
eeg_signal_with_artifact = eeg_signal_with_noise + muscle_artifact;
% Plot simulated EEG signal with noise and artifact

% figure;
% plot(t, eeg_signal_with_artifact);
% xlabel('Time (s)');
% ylabel('EEG Amplitude');
% title('Simulated EEG Signal with Noise and Muscle Artifact');
% legend('EEG Signal with Noise and Artifact');

eeg_final = [t(:) eeg_signal_with_artifact(:)];


