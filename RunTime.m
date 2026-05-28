% script per allenare il modello Simulink che sarà usato per l'evaluation (Modello_evaluation_Unicorn_NEW)
% secondo quelle che nello script di OfflineDataAnalysis sono state trovate
% come best window e best features sugli stessi run di calibrazione.  
addpath('DATA/')
addpath("FUNCTIONS/")
load("best_interval.mat") ;
fs = 250;

% ALGORITHM PARAMETERS
% Pre-processing
check_short_trials = 1;
norm_baseline = 0;
tmin_baseline = 0;
tmax_baseline = 8;

% TRAINING ALGORITHM
tr_param = [];

% Initialize classes
class2 = 2;                 % 2: right imagery
class3 = 3;                 % 3: rest 

% Algorithm hyperparameters
m = 3;                   % CSP components

% Training data selection
ch = 1:8;                   
trials = 1:45;              

% Stop trial
tMinStop = 8;

% LOAD DATA FROM BLOCK WITHOUT FEEDBACK (B0) %sarebbero i dati di calibrazione!
[file,path] = uigetfile('*.mat', 'Select one or more B0 files from the corresponding session', 'MultiSelect', 'on');

if ischar(file) %se è un solo run allora fileT è un char
    subID = strsplit(file,'_');
    session = subID{1,2};
    subID = subID{1,1};
    nRuns = 1;
else            %se è più di un run fileT è una cella di dimensioni (1xnRuns)
    subID = strsplit(file{1,1},'_');
    session = subID{1,2};
    subID = subID{1,1};
    nRuns = length(file);
end

% SHORT TRIALS REMOVAL
if check_short_trials == 1
    disp('Removing short trials...')
    if ischar(file)
        nrun = 1;
    else
        nrun = length(file);
    end

    for run = 1:nrun
        if ischar(file)
            load(strcat(path,file))
        else
            load(strcat(path,file{run}))
        end
    
        p = [diff(data{1,1}.trial); size(data{1,1}.X,1)-data{1,1}.trial(end)];
        short = zeros(length(p),1);
        for i = 1:length(p)
            if p(i)<(tMinStop)*data{1,1}.fs
                short(i) = 1;
            end
        end
        % Remove trials shorter than 8.0 s
        data{1, 1}.trial(short==1)=[];
        data{1, 1}.y(short==1)=[];
        data{1, 1}.artifacts(short==1)=[];
        disp(['The number of removed trials in run ',num2str(run),' is ',num2str(sum(short))])
        if sum(short)>0
            save(strcat(path,file{run}),'data','nf','notes','files')
        end
    end
    clear run p short i block
end

% load data
if (ischar(file))
    nfil = 1;
else
    nfil = length(file);
end

best_tmin_a = best_win_a(1) ;
best_tmax_a = best_win_a(2) ;
best_feat_a = best_feat ;

% BASELINE REMOVAL
imageryT_a = [];
classT_a =[];

for fls = 1:nfil
    try
        pathDATA = strcat(path,file{1,fls});
    catch
        pathDATA = strcat(path,file);
    end
    
    % Baseline extraction and normalization
    if norm_baseline == 1  
        disp('Baseline removal...')
        % Signal extraction
        [imagery, class_temp, fs, runs, ~ , trials] = extraction(pathDATA, [], ch, [], tmin_baseline, tmax_baseline,5);
        l_ch = length(ch);
        l_tr = length(trials);
        l_r = length(runs);
        imagery_baseline = zeros(l_ch,fs*(tmax_baseline-tmin_baseline),l_tr*l_r);
        for c_b = 1:l_tr*l_r
            imagery_baseline (:,:,c_b) = imagery(1+l_ch*(c_b-1):l_ch+l_ch*(c_b-1),:);
        end
        % Removing 100 ms before the cue
        EEG_LB_mean_rep=EEGbaseline(imagery_baseline,fs*1.9,fs*2.0);
        imagery_baseline = permute(EEG_LB_mean_rep,[1,3,2]);
        bas_norm = reshape(imagery_baseline,[size(imagery_baseline,1)*size(imagery_baseline,2),size(imagery_baseline,3)]);
        % Baseline removing
        imagery_temp = imagery-bas_norm;

        %motion vs rest
        wind_min_a = round(best_tmin_a*fs);
        wind_max_a = round(best_tmax_a*fs);
        imagery_temp_a = imagery_temp(:,wind_min_a:wind_max_a);

        class_temp_a = class_temp(class_temp == class2 | class_temp == class3,:);      
        imageryT_a = [imageryT_a; imagery_temp_a];        
        classT_a = [classT_a; class_temp_a];               

    else
        [imagery_temp_a, class_temp_a, fs] = extraction(pathDATA, [], ch, [], best_tmin_a, best_tmax_a, 5);
      
        imageryT_a = [imageryT_a; imagery_temp_a];        
        classT_a = [classT_a; class_temp_a];              

    end
end

winLen    = 2*fs;    %length of the time window
shiftLen  = 0.20*fs; %length of the shift
epochLen  = 8*fs;    %length of the epoch

% Motion vs rest
EEGa = imageryT_a(classT_a == class2 | classT_a == class3, :);
classT_a = classT_a(classT_a == class2 | classT_a == class3);


% ALGORITHM TRAINING

% FILTER BANK
%left vs right
if (exist('hd','var'))
    EEGa = filterBankCOYLE(EEGa,fs,hd);
else
    [EEGa, hd] = filterBankCOYLE(EEGa,fs);
end

% CSP 
[W1a,W2a] = CSPtrain(EEGa,classT_a, ch, m);
[V1a,~,~,~,Ya] = CSPapply(EEGa,classT_a,W1a,W2a,[],[]);

% FEATURE SELECTION
[Ia,SIa] = fscmrmr(V1a, Ya);
ind_sel_a = Ia(1:best_feat_a);
fa = V1a(:,ind_sel_a);

% TRAINING
Mdl_a = fitcdiscr(fa,Ya,'DiscrimType','linear','Gamma',0,'Prior', [0.3, 0.7]);
coeffs_a = Mdl_a.Coeffs; %struct con i coefficienti
linear_coeffs_a = Mdl_a.Coeffs(1,2).Linear;
const_a         = Mdl_a.Coeffs(1,2).Const;

buffLen = 16; %servirà per le metriche nell'evaluation su Simulink

%% per caricare un raw EEG su Simulink in assenza del caschetto
addpath(genpath('sample data for calibration'));
load('AntEsp_S3_B0_3.mat')
ERaw = data{1,1}.X';

% disp('Avvio della simulazione Simulink in corso...');
% % Esegue il modello e salva i risultati nella variabile 'out'
% out = sim('Modello_evaluation_Unicorn'); 
% disp('Simulazione completata.');

%% Salva dopo app evaluation
%save(['EvData/',subID,'_',session,'_ev.mat'],'out');