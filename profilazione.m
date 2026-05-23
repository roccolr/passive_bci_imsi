% --- SETUP --- 

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

%% --- VARIABLES --- 

unicorn_f = 250 % hz
unicorn_buff_size = 25 % numero di campioni in un frame ricevuto da unicorn
amplitude_1 = 20e-6
amplitude_2 = 30e-6
amplitude_3 = 40e-6
amplitude_4 = 50e-6

calibration_duration = 60 % secondi
campioni_per_run = calibration_duration*unicorn_f
%%
% --- ACQUISIZIONE --- 

numero_osservazione = 1;
nome_soggetto = "Alfo";
gender_soggetto = "male";

% DATASET: struct con due matrici 30x6 (30 osservazioni di 6 valori)
% --- DEFINIZIONE STRUTTURA DATI --- 😱🤢
tbr_matrix = zeros(30,6);
ei_matrix = zeros(30,6);

dataset.nome = nome_soggetto;
dataset.gender = gender_soggetto;
dataset.data = out.yout(15001:30000, :);
dataset.numero_osservazione = numero_osservazione;


save("dataset_alfo/"+num2str(numero_osservazione)+".mat", 'dataset');
fprintf("Osservazione %d salvato con successo\n", numero_osservazione);

%% 

path_generico = "./dataset_alfo/";
m_tbr = zeros(1,30);
m_ei = zeros(1,30);

for i = 1:30
    path=path_generico+num2str(i)+".mat";
    data = load(path).dataset.data;

    [tbr_vector, ei_vector] = utils.process_data(data);
    m_tbr(i) = mean(tbr_vector);
    m_ei(i) = mean(ei_vector);
end

%%

% --- DATA PROCESS ---
x_tbr = mean(m_tbr);
std_tbr = std(m_tbr);

x_ei = mean(m_ei);
std_ei = std(m_ei);

C_L = 0.99; % confidence interval
alpha = 1-C_L; % significance 

t_crit_TBR = tinv(1 - alpha/2, 29);
t_crit_EI = tinv(1-alpha/2, 29);

margin_of_error_TBR = t_crit_TBR * (std_tbr / sqrt(30));
margin_of_error_EI = t_crit_EI * (std_ei / sqrt(30));

ci_lower_TBR = x_tbr - margin_of_error_TBR;
ci_upper_TBR = x_tbr + margin_of_error_TBR;

ci_lower_EI = x_ei - margin_of_error_EI;
ci_upper_EI = x_ei + margin_of_error_EI;

fprintf("[MAIN]\tMEDIA TBR: \t%.3f\tCL %.1f\t\tCI [%.4f, %.4f]\n", x_tbr, 100*C_L, ci_lower_TBR, ci_upper_TBR);
fprintf("[MAIN]\tMEDIA EI: \t%.3f\tCL %.1f\t\tCI [%.4f, %.4f]\n", x_ei, 100*C_L, ci_lower_EI, ci_upper_EI);

