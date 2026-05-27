close all; clear; clc
addpath("FUNCTIONS/");

%Script per trovare best window e best features dopo l'acquisizione
%dell'EEG per diversi run di calibrazione (nel nostro caso 3 o 2).
%Segue experimentalProtocol_Unicorn
%Initialize classes
class2 = 2;                 % 2: right imagery
class3 = 3;                 % 3: rest

% Pre-processing
check_short_trials = 1;
norm_baseline = 0;

% Repeated Stratified K-Fold CV
k_folds = 5;                % number of folds
n_repts = 10;               % number of repetitions

% Algorithm hyperparameters
m = 3;                      % CSP components
% (The number of selected CSP filter pairs for each frequency band (m) was set to three and represents
% the first m and the last m columns of the transformation matrix W considered for each class)
 
% Training data selection
ch = 1:8;

%tmin e tmax sono gli istanti temporali che servono alla funzione per
%capire da che punto a che punto estrarre il segnale
tmin = 0;
tmax = 8;
tMinStop = 8;

tshift = 0.20;
twin = 2;
nwin = floor((tmax-tmin-twin)/tshift)+1; %con i dati scelti è 31 il numero di finestre totale da 0 a 8.
%ma se consideriamo tmin 2 e tmax 6 il numero di finestre cambia e diventa 11

%% CHOOSE DATA TO ANALYZE
[fileT, pathT] = uigetfile('*.mat', 'Select one or more files to analyze in CV', 'MultiSelect', 'on');

%% SHORT TRIALS REMOVAL
if check_short_trials == 1
    disp('Removing short trials...')
    if ischar(fileT)
        nrun = 1;
    else
        nrun = length(fileT);
    end
    for run = 1:nrun
        if ischar(fileT)
            load(strcat(pathT,fileT))
        else
            load(strcat(pathT,fileT{run}))
        end
    
        p = [diff(data{1,1}.trial); size(data{1,1}.X,1)-data{1,1}.trial(end)];
        short = zeros(length(p),1);
        for i = 1:length(p)
            if p(i)<(tMinStop)*data{1,1}.fs
                short(i) = 1;
            end
        end
        % Remove trials shorter than 9.0 s
        data{1, 1}.trial(short==1)=[];
        data{1, 1}.y(short==1)=[];
        data{1, 1}.artifacts(short==1)=[];
        disp(['The number of removed trials in run ',num2str(run),' is ',num2str(sum(short))])
        if ischar(fileT)
    block = split(fileT, '_');
else
    block = split(fileT{run}, '_');
end
        block = block(3);
        % if sum(short)>0
        %     if block == "B0"
        %         save(strcat(pathT,fileT{run}),'data','nf','notes','files','StatoFisicoMentale')
        %     else
        %         save(strcat(pathT,fileT{run}),'data','notes','tr_param','nfp','StatoFisicoMentale')
        %     end
        % end
    end
    clear run p short i block
end
% load data
if (ischar(fileT))
    nfil = 1;
else
    nfil = length(fileT);
end

%% BASELINE REMOVAL %qui potremmo implementare un possibile allineamento (Reimanniano o Euclideo)
imageryTot = [];
classTot = [];
for fls = 1:nfil
    try
        pathDATA = strcat(pathT,fileT{1,fls});
    catch
        pathDATA = strcat(pathT,fileT);
    end
    
    % Baseline extraction and normalization
    if norm_baseline == 1        
        disp('Baseline removal...')
        % Signal extraction
        [imagery, class_temp, fs, runs, ~ , trials] = extraction(pathDATA, [], ch, [], tmin, tmax, 5);
        l_ch = length(ch);
        l_tr = length(trials);
        l_r = length(runs);
        imagery_baseline = zeros(l_ch,fs*(tmax-tmin),l_tr*l_r);
        for c_b = 1:l_tr*l_r
            imagery_baseline (:,:,c_b) = imagery(1+l_ch*(c_b-1):l_ch+l_ch*(c_b-1),:);
        end
        % Removing 100 ms before the cue
        EEG_LB_mean_rep=EEGbaseline(imagery_baseline,fs*1.9,fs*2.0);
        imagery_baseline = permute(EEG_LB_mean_rep,[1,3,2]);
        bas_norm = reshape(imagery_baseline,[size(imagery_baseline,1)*size(imagery_baseline,2),size(imagery_baseline,3)]);
        % Baseline removing
        imagery_temp = imagery-bas_norm;
        
        imageryTot = [imageryTot; imagery_temp];        %#ok
        classTot = [classTot; class_temp];              %#ok
    else
        [imagery_temp, class_temp, fs] = extraction(pathDATA, [], ch, [], tmin, tmax, 5);
        %   'imagery_temp' is an array containing EEG signals in the time window;
        %   the array rows corrispond to trials: they are grouped by channel
        %   and they can be divided by runs; the coloumns are time samples.
        imageryTot = [imageryTot; imagery_temp];        %#ok mette in un'unica matrice tutti i run di calibrazione che si caricano all'inizio
        classTot = [classTot; class_temp];              %#ok
    end
end

%% CROSS-VALIDATION ON DIFFERENT TIME WINDOW WIDTHS  [ora abbiamo una sola finestra]
disp('Cross validation results:')

accuracy_time = zeros(nwin,1);
std_time = zeros(nwin,1);                                  
confusion_time = zeros(nwin,2,2);
conf_STD_time = zeros(nwin,2,2);

for w = 1:nwin 
    wind_min = round(1+(tmin+tshift*(w-1))*fs);
    wind_max = round((tmin+twin+tshift*(w-1))*fs);

    imageryT = imageryTot(:,wind_min:wind_max); 
    classT = classTot;
    
    %FILTER BANK
    if (exist('hd','var'))
        EEG = filterBankCOYLE(imageryT,fs,hd);
    else
        [EEG, hd] = filterBankCOYLE(imageryT,fs);
    end

    % SELEZIONE: Filtra solo Destra (class2) e Riposo (class3)
    % Assicurati che classTot contenga i valori originali 2 e 3
    idx_da_tenere = (classT == class2 | classT == class3);
    EEG = EEG(idx_da_tenere, :, :);
    classT_a = classT(idx_da_tenere, :);

    CLASSa = classT_a;

    % 
    % %motorio contro riposo                    
    % EEG = EEG(classT == class2 | classT == class3, :,:);
    % classT_a = classT(classT == class2 | classT == class3,:);
    % 
    % CLASSa = classT_a;

    % Ora il reshape funzionerà perché EEG ha un numero di righe 
    % multiplo di nch (8)
    nch = length(ch);
    EEG = reshape(EEG, [nch, size(EEG,1)/nch, size(EEG,2), size(EEG,3)]);
    CLASSa = reshape(CLASSa, [nch, size(CLASSa,1)/nch]);
    
    % CROSS-VALIDATION
    % stratified k-fold partition with repeations
    cst_a = cvpartition(CLASSa(1,:),'KFold', k_folds);
    cvPart.numTestSet_a = k_folds*n_repts;
    c_a = cst_a;
    for rep = 1:n_repts
        for ind = 1:k_folds
            cvPart.testInd_a{(rep-1)*k_folds+ind} = test(c_a,ind);
            cvPart.trainInd_a{(rep-1)*k_folds+ind} = training(c_a,ind);
        end
        c_a = repartition(c_a);
    end

    % cross-validation risultati
    accuracy_cross_a = zeros(cvPart.numTestSet_a,1);
    confusion_crss_a = zeros(2,2,cvPart.numTestSet_a);

    for k = 1:cvPart.numTestSet_a

        % Split dataset for train and test
        classEv_a = CLASSa(:,cvPart.testInd_a{k});
        classTr_a = CLASSa(:,cvPart.trainInd_a{k});

        eegEv_a = EEG(:,cvPart.testInd_a{k},:,:);
        eegTr_a = EEG(:,cvPart.trainInd_a{k},:,:);

        % Reshape
        classTr_a = reshape(classTr_a,[nch*size(classTr_a,2), 1]);
        eegTr_a = reshape(eegTr_a,[nch*size(eegTr_a,2), size(eegTr_a,3), size(eegTr_a,4)]);

        classEv_a = reshape(classEv_a,[nch*size(classEv_a,2), 1]);
        eegEv_a = reshape(eegEv_a,[nch*size(eegEv_a,2), size(eegEv_a,3), size(eegEv_a,4)]);

        % CSPcomposite 
        % csp 2 tasks training
        [W1a,W2a] = CSPtrain(eegTr_a, classTr_a, ch, m);
        [V1a,~,~,~,Ya] = CSPapply(eegTr_a,classTr_a,W1a,W2a,[],[]);

        % features selection
        % fscmrmr classifica le features per la classificazione usando un
        % algoritmo di minima ridondanza e massima rilevanza (MRMR) per
        % identificare predittori importanti. In particolare I è un vettore
        % numerico di indici dei predittori ordinati per importanza (indici
        % corrispondenti alle features più importanti); SI è un vettore
        % numerico con gli score (normalizzati) dei predittori (quasi tutti 0 tranne
        % quelli delle features più importanti)
        [Ia,SIa] = fscmrmr(V1a, Ya);
        ind_sel_a=[];
        l=1;
        for j = 1:length(SIa)
 
            if SIa(j) == 0
                continue %continue salta le istruzioni rimanenti nel for loop e inizia l’iterazione successiva
            end
           
            if SIa(j) ~= 0
                ind_sel_a (l) = j;
                l = l+1;
            end
  
        end

        if isempty(ind_sel_a) == 1; %mettendo questa istruzione il codice smette di dare errore perchè fa sarà sempre non vuoto
            ind_sel_a = Ia; %se nessuna feature è importante, prendile tutte; così accuracy_cross non potrebbe più avere degli 0
        end
 
        save_ind_sel_a{k,w} = ind_sel_a; %in questo modo salvo una matrice di celle 50*31 (kxw) però in ogni cella c'è un vettore che è ind_sel a ogni iterazione di k e w

        % LDA training per le best features
        fa = V1a(:,ind_sel_a);  %il problema qua era: fa è 0 a un certo punto se non ci sono SIa non nulle perchè ind_sel è vuoto
        Mdl_a = fitcdiscr(fa,Ya,'DiscrimType','linear','Gamma',0);

        % evaluation
        [V1a_ev,~,~,~,Ya_ev] = CSPapply(eegEv_a,classEv_a,W1a,W2a,[],[]);
        fa_ev = V1a_ev(:,ind_sel_a);

        %accuracy
        [lbl_a, score_a] = predict(Mdl_a,fa_ev); 
        % if k == 1 %solo per la prima iterazione
        %     figure
        %     histogram(score_a(:,1));
        %     title('Distribuzione dei punteggi per il modello a (LEFT) su fold 1')
        %     xlabel('punteggio')
        %     ylabel('frequenza')
        % end

        accuracy_cross_a(k) = mean(lbl_a == Ya_ev);
        confusion_crss_a(:,:,k) = confusionmat(Ya_ev,lbl_a); %la matrice di confusione restituisce una rappresentazione 
        % dell'accuratezza di classificazione statistica. Ogni colonna della matrice rappresenta i valori predetti, 
        % mentre ogni riga rappresenta i valori reali.

        %accuracy_cross_a_collected(k,w) = mean(lbl_a == Ya_ev);

    end

    clear l

    % save accuracy and standard deviation for each window
    accuracyCV_a = mean(accuracy_cross_a);
    stdCV_a = std(accuracy_cross_a);
    
    disp(['In time window [',num2str(tmin+tshift*(w-1)),' , ', num2str(twin+tmin+tshift*(w-1)),...
        '] the mean accuracy for motion vs relax is ',num2str(accuracyCV_a), ' +/-' num2str(round(stdCV_a,2))])

    
    % save accuracy data
    accuracy_time_a(w) = accuracyCV_a;
    std_time_a(w) = stdCV_a;
    
    
    conf_media = mean(confusion_crss_a, 3); % Media delle matrici di confusione sui k-fold

% Normalizzazione corretta per riga (accuratezza per singola classe)
% confusionmat mette i valori veri sulle righe:
% riga 1: Classe Motion, riga 2: Classe Rest
acc_classe_motion = conf_media(1,1) / sum(conf_media(1,:));
acc_classe_rest   = conf_media(2,2) / sum(conf_media(2,:));

confusion_time_a(w,1,1) = acc_classe_motion;
confusion_time_a(w,2,2) = acc_classe_rest;
    conf_STD_time_a(w,:,:) = std(confusion_crss_a,[],3)/(length(Ya_ev)/2);

end
 %%fino a qui funziona

%% PLOT RESULTS
% motorio vs riposo
t = 0:tshift:6;
 
% Forziamo i dati a colonna per evitare errori di mismatch
accuracy_time= accuracy_time_a(:);
std_time = std_time_a(:);

figure
subplot(1,2,1)
boundedline(t, 100*accuracy_time, 100*std_time,'*--')
ylim([0 100])
xticks(4:0.2:6)
title('Mean accuracy (Motion vs Rest)')
grid 
 
subplot(1,2,2)
plot(t,100*confusion_time_a(:,1,1),'*--') %motion (right)
hold on
plot(t,100*confusion_time_a(:,2,2),'r*--') %rest
legend('accuracy class motion', 'accuracy class Rest','Location','NorthWest')
title('Accuracy per class')
ylim([0 100])
xticks(3:0.20:7)
grid

sgtitle('Each point (i) shows the accuracy reached in the window [i-2s, i]')


%% BEST WINDOW & BEST FEATURES
%accuracy_time contiene una colonna e sulle 11 righe la media delle k(=50) accuracy
%per ogni w(da 1 a 31)

%accuracy_time quindi contiene i valori medi di accuracy raggiunti nelle w(=31)
%windows overlappate in cui è diviso il segnale. t contiene i w(=31) tempi
%di start di ogni finestra, quindi va da 0 a 6 con uno shift di 0.2


%fatto ciò, oltre a trovare la best win, devo anche considerare la
%differenza tra le due classi (confusion time nel punto 1,1 e
%2,2).  %la matrice di confusione restituisce una rappresentazione 
        % dell'accuratezza di classificazione statistica. 
        % Ogni colonna della matrice rappresenta i valori predetti, 
        % mentre ogni riga rappresenta i valori reali.

tMIstart = find(t >= 4, 1, 'first'); % Trova il primo indice >= 4s
tMIstop  = find(t <= 6, 1, 'last');  % Trova l'ultimo indice <= 6s
tExp = t(tMIstart:tMIstop); 

MI_accuracy_time_a = accuracy_time_a(tMIstart:tMIstop);
[best_MI_accuracy_time_a,best_pos_a]= max(MI_accuracy_time_a);
idx_global_a = best_pos_a + tMIstart - 1; %ricostruisco l'idx globale corrispondente alla best accuracy nella finestra di MI
if confusion_time_a(idx_global_a,1,1)>0.60
    best_win_a = [tExp(best_pos_a), (tExp(best_pos_a)+twin)]
elseif confusion_time_a(idx_global_a,1,1)<0.60
    disp('Error: classification accuracy "motion vs rest" is unbalanced for one class')
end

%a questo punto, avrò 50 celle fatte da vettori di indici, x 31 colonne, quante sono le windows
%(save_ind_sel_a(:,idx_global_a) per esempio)
%----->voglio selezionare il numero migliore (con istogramma, vedi quante 
%volte compare un certo indice) di feature in corrispondenza della best window 
%per questo mi serve l'idx_global che ho convertito in precedenza a partire
%dalla ricerca della max accuracy solo nella finestra di MI

feat_cell_a = save_ind_sel_a(:,idx_global_a); %50x1

store_IND_a = cat(2, feat_cell_a{:}); 
%2 è la dimensione lungo la quale va a concatenare (colonna) il contenuto 
%delle 50 celle di feat_cell_a in modo da farlo diventare un vettore riga
%che si può istogrammare

%istogrammi delle features selezionate per capire quali ricorrono più spesso
figure
ha = histogram(store_IND_a,"BinEdges",[-0.5:24.5])
title('feature index occurrence for motion vs relax')
xticks(1:24);
hold on
yline(5,'r','5','LineWidth',1.5)
val_a = ha.Values>5;

best_feat_a_idx = find(val_a)-1; %restituisce gli indici (0-based) delle features buone 
%cioè che ricorrono > 5 

fprintf('\nThe best interval for motion vs relax is [%.1f, %.1f], with %d features. (%.0f%%)\n', ...
    tExp(best_pos_a), ...
    tExp(best_pos_a) + twin, ...
    length(best_feat_a_idx), ...
    round(best_MI_accuracy_time_a, 2) * 100);

best_feat = length(best_feat_a_idx) ;
save("best_interval.mat", "best_win_a", "best_feat");