function signals = extraction(dataset_path, run)
    % Dataset file (.mat) -> Nx8 channel signal
    data = load(dataset_path);
    signals = data.data{1,run}.X(:, [1,10,20]); % [Fz Cz Pz]
    fprintf('Segnali estratto con successo\n');
    