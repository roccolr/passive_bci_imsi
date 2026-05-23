function [tbr_vector, ei_vector]= process_data(data)
    tbr_vector = zeros(1,6);
    ei_vector = zeros(1,6);
    fs = 250;
    % --- PULIZIA ---
    [b_bp, a_bp] = butter(4, [1, 40]/(fs/2), 'bandpass');
    cleaned_data = filtfilt(b_bp, a_bp, data);
    n_chan = 8;
    fs = 250;
    unicorn_f = fs;
    try
        fprintf('Esecuzione ASR (EEGLAB) per rimozione blinks...\n');
        % ASR richiede i dati in formato (Canali x Campioni) -> Trasponiamo
        EEG_temp = pop_editset(eeg_emptyset, 'data', cleaned_data', 'srate', fs, 'nbchan', n_chan);

        % Esecuzione clean_artifacts 
        ASR = clean_artifacts(EEG_temp, 'WindowCriterion', 'off', 'chancorr_crit', 'off', 'line_crit', 'off');

        % Ripristiniamo il formato NxM
        cleaned_data = double(ASR.data)';
    catch ME
        warning(['Rimozione ASR fallita (EEGLAB non trovato?). Uso solo filtri base. Dettaglio: ', ME.message]);
    end


    % --- CALCOLO INDICI --- 
    win_sec = 2;
    win_len = round(win_sec*fs);
    overlap = 0.5;
    N = 2500;
    nCh = 3;
    step = round(win_len * (1-overlap));
    num_win = floor((N-win_len)/step) +1;

    for j=1:6

        temp_data = cleaned_data(1+(j-1)*2500:j*2500, :);
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


        for ch = [1,3,5]
            x = temp_data(:, ch);
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

        tbr_vector(j) = median(TBR_mean);
        ei_vector(j) = median(EI_mean);
    end
    
end
