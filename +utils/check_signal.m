function [result, channels] = check_signal(signals, threshold_max, threshold_min)
    [rows, cols] = size(signals)
    channels = []
    for i = 1:cols
        result = true;
        signal = signals(:,i);
        max_signal = max(signal);
        min_signal = min(signal);
        if max_signal >= threshold_max 
            result = false;
        end 
        if min_signal <= threshold_min 
            result = false; 
        end 
        if result == false
            channels = [channels, i];
        end 
    end
end

