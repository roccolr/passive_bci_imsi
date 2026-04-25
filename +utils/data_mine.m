% To do: 
% 1 - Estrarre per ogni soggetto e per ogni run indici medi EI e TBR 
% 2 - [EI1 EI2 ... EIn] , [TBR1 ... TBRn] -> pmf n = 48
% 3 - t-transform  -> intervalli di confidenza 
% 4 - plot della pmf originale non trasformata 

%% 0
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

delete("./vanilla_acquired_data/*");
delete("./cleaned_data/*");
num_runs = 6;
%% 1 

projectRoot = pwd;
targetDir = fullfile(projectRoot, 'dataset'); 
fileList = dir(fullfile(targetDir, '**', '*.*'));
fileList = fileList(~[fileList.isdir]);
relativePaths = strings(length(fileList), 1); % realtive paths -> vettore con i path dei dataset dei soggetti [1:9] 
TBR_pmf = zeros(size(relativePaths,1)*num_runs, 1);
EI_pmf = zeros(size(relativePaths,1)*num_runs, 1);


for i = 1:length(fileList)

    absolutePath = fullfile(fileList(i).folder, fileList(i).name);
    baseRelative = extractAfter(absolutePath, [projectRoot, filesep]);
    

    unixStylePath = strrep(baseRelative, '\', '/');
    

    finalPath = "./" + string(unixStylePath);
    

    relativePaths(i) = finalPath;

end


for k = 1:length(relativePaths)
    
    raw_data_paths = {}; 
    clean_data_paths = {};

    for i = 4:9
    
        signals = utils.extraction(relativePaths(k), i);
        [result, channels] = utils.check_signal(signals, 100, -100); % bisogna eliminare solo il segmento sporco di segnale

        % if result == true
        %     fprintf("segnale buono...\n");
        % else 
        %     for j = 1:length(channels)
        %         fprintf("segnali cattivi: %d\n", channels(j)); 
        %     end
        % end 
        subFolder = 'vanilla_acquired_data';
        fileName = sprintf('dataset_sample_%s_run%d.mat', datestr(now, 'yyyy-mm-dd_HH-MM-SS'), i);

        if ~exist(subFolder, 'dir')
            mkdir(subFolder);
        end

        targetPath = fullfile(pwd, subFolder, fileName);
        save(targetPath, 'signals');
        raw_data_paths{end+1} = targetPath; % Append to cell array
    
    end 
    for i = 1:length(raw_data_paths)
        % Passing character vector instead of string object
        clean_signals_path = utils.remove_artifacts_eeg(raw_data_paths{i}, 250);

        % Ensure load works correctly by specifying the expected variable
        loaded_data = load(clean_signals_path);
        clean_signals = loaded_data.signals;
        clean_data_paths{end+1} = clean_signals_path;
    end

    TBR_vector = [];
    EI_vector = [];

    for i = 1:length(clean_data_paths)
        [TBR_temp, EI_temp] = utils.retrieve_indexes(clean_data_paths{i}, 250, 2, 0.5);
        l = length(clean_data_paths);
        % TBR_vector = [TBR_vector TBR_temp];
        % EI_vector = [EI_vector EI_temp];
        TBR_pmf(l*(k-1)+i) = TBR_temp;
        EI_pmf(l*(k-1)+i) = EI_temp;
    end 

    % TBR_mean_final = mean(TBR_vector);
    % EI_mean_final = mean(EI_vector); 


end

%% plt istogramma 


figure(1)
histogram(TBR_pmf, 20);
hold on

figure(2)
histogram(EI_pmf, 20);

%%
% Normalizzazione 

C_L = 0.95; % confidence interval
alpha = 1-C_L; % significance 


n_TBR = size(TBR_pmf, 1);
df_TBR = n_TBR-1;
x_TBR = mean(TBR_pmf);
s_TBR = std(TBR_pmf);

n_EI = size(EI_pmf, 1);
df_EI = n_EI-1;
x_EI = mean(EI_pmf);
s_EI = std(EI_pmf);


t_crit_TBR = tinv(1 - alpha/2, df_TBR);
t_crit_EI = tinv(1-alpha/2, df_EI);


margin_of_error_TBR = t_crit_TBR * (s_TBR / sqrt(n_TBR));
margin_of_error_EI = t_crit_EI * (s_EI / sqrt(n_EI));

ci_lower_TBR = x_TBR - margin_of_error_TBR;
ci_upper_TBR = x_TBR + margin_of_error_TBR;

ci_lower_EI = x_EI - margin_of_error_EI;
ci_upper_EI = x_EI + margin_of_error_EI;

fprintf("[MAIN]\tMEDIA TBR: %.3f\t CL %.1f\tCI [%.4f, %.4f]\n", x_TBR, 100*C_L, ci_lower_TBR, ci_upper_TBR);
fprintf("[MAIN]\tMEDIA EI: %.3f\t CL %.1f\tCI [%.4f, %.4f]\n", x_EI, 100*C_L, ci_lower_EI, ci_upper_EI);