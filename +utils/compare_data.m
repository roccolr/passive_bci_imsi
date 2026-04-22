function compare_data(dirty_path, clean_path)
% COMPARE_EEG_FILTERING Confronta i segnali EEG prima e dopo la pulizia.
%
%   INPUT:
%   - dirty_path: Stringa con il percorso del file .mat grezzo.
%   - clean_path: Stringa con il percorso del file .mat pulito.

% 1. Caricamento dei dati "sporchi"
fprintf('Caricamento dati grezzi da: %s\n', dirty_path);
dirty_struct = load(dirty_path);
var_dirty = fieldnames(dirty_struct);
dirty_data = dirty_struct.(var_dirty{1});

% 2. Caricamento dei dati "puliti"
fprintf('Caricamento dati puliti da: %s\n', clean_path);
clean_struct = load(clean_path);
var_clean = fieldnames(clean_struct);
clean_data = clean_struct.(var_clean{1});

% Controllo di coerenza delle dimensioni
if size(dirty_data, 1) ~= size(clean_data, 1)
    warning('I due file hanno un numero diverso di campioni. Il grafico potrebbe risultare disallineato.');
end

% Colonne richieste per il plot (1, 3, 5)
cols_to_plot = [1, 3, 5];
% Nomi dei canali corrispondenti al setup Unicorn standard
channel_names = {'Canale 1 (Fz)', 'Canale 3 (Cz)', 'Canale 5 (Pz)'};

% Creazione della figura a schermo intero o ingrandita
figure('Name', 'Confronto EEG Pre/Post Filtraggio', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);

% Ciclo per generare i 3 subplot
for i = 1:length(cols_to_plot)
    col_idx = cols_to_plot(i);

    subplot(3, 1, i);

    % Plot del segnale grezzo in rosso chiaro
    plot(dirty_data(:, col_idx), 'Color', [0.85, 0.32, 0.09, 0.6], 'DisplayName', 'Segnale Grezzo (Sporco)');
    hold on;

    % Plot del segnale pulito in blu scuro, con linea leggermente più spessa
    plot(clean_data(:, col_idx), 'Color', [0, 0.44, 0.74], 'LineWidth', 1.2, 'DisplayName', 'Segnale Pulito (Filtrato)');

    % Formattazione del grafico
    title(channel_names{i});
    xlabel('Campioni');
    ylabel('\muV');
    grid on;
    legend('Location', 'northeast');

    % Blocchiamo i limiti dell'asse X per allinearli ai dati
    xlim([1, max(length(dirty_data), length(clean_data))]);
end

% Titolo generale della finestra
sgtitle('Confronto effetti di Filtraggio e ASR sui canali selezionati');

fprintf('Grafici generati con successo.\n');
end