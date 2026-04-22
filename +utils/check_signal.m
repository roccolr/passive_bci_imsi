function [result, channels] = check_signal(signals, threshold_max, threshold_min)
    
    channels = []
    for i = 1:8
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

