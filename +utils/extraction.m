function signals = extraction(dataset_path)
    % Dataset file (.mat) -> Nx8 channel signal
    data = load(dataset_path);
    signals = data.data{1,1}.X(1:2500, 1:8);
    fprintf('Segnali estratto con successo\n');
