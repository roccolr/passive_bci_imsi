function [TBR_value, EI_value] = retrieve_indexes(path,f_samp,win_sec, overlap)
    unicorn_f = f_samp;
    eeg_without_artifacts_data = load(path);
    eeg_without_artifacts_data = eeg_without_artifacts_data.signals;
    win_len = round(win_sec*unicorn_f);
    step = round(win_len * (1-overlap));
    [N, nCh] = size(eeg_without_artifacts_data);
    num_win = floor((N-win_len)/step) +1;

    % DATA STRUCTURES
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

    for ch = 1:nCh 
        x = eeg_without_artifacts_data(:, ch);
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

    TBR_value = median(TBR_mean);
    EI_value = median(EI_mean);
    
    % % Primo grafico in alto
    % subplot(2, 1, 1); 
    % scatter(1:length(EI_mean), EI_mean, 'b');
    % grid on;
    % title('EI');
    % ylabel('EI');
    % 
    % % Secondo grafico in basso
    % subplot(2, 1, 2); 
    % scatter(1:length(TBR_mean), TBR_mean, 'r');
    % grid on;
    % title('TBR');
    % ylabel('TBR');
    % 
    % fprintf("[MAIN]\tTBR mediano: %.3f\n", TBR_value);
    % fprintf("[MAIN]\tEI mediano: %.3f\n", EI_value);