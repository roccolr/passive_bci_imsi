function [data_out, valid] = check_artifacts_realtime(data)

threshold_max = 100;
threshold_min = -100;
min_bad_samples = 10;

data_out = data;

[~, nCh] = size(data);

valid = 1;

for ch = 1:nCh

    x = data(:,ch);

    bad_samples = sum(x > threshold_max | x < threshold_min);

    if bad_samples >= min_bad_samples
        valid = 0;
    end

end