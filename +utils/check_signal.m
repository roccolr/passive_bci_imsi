function result = check_signal(signals, threshold_max, threshold_min)
    result = true
    for i = 1:8
        signal = signals(:,i);
        max_signal = max(signal);
        min_signal = min(signal);
        if max_signal >= threshold_max 
            result = false
        end 
        if min_signal <= threshold_min 
            result = false 
        end 
    end
end

