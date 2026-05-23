import os
import pandas as pd
import scipy.io as sio

def convert_all_csv_to_mat(folder_in, folder_out):
    """
    Converte tutti i file .csv di folder_in in .mat e li salva in folder_out.
    """
    if not os.path.exists(folder_in):
        print(f"Errore: Il percorso di origine '{folder_in}' non esiste.")
        return

    # Crea la cartella di destinazione se non esiste
    os.makedirs(folder_out, exist_ok=True)

    # Iterazione all'interno della cartella
    for filename in os.listdir(folder_in):
        if filename.endswith('.csv'):
            csv_path = os.path.join(folder_in, filename)
            
            # Generazione del nome del file .mat
            mat_filename = os.path.splitext(filename)[0] + '.mat'
            
            # CORREZIONE: Unione del percorso della cartella di destinazione con il nome del file
            mat_path = os.path.join(folder_out, mat_filename)
            
            try:
                # Lettura e conversione
                df = pd.read_csv(csv_path)
                data_matrix = df.to_numpy()
                
                # Salvataggio
                sio.savemat(mat_path, {'data': data_matrix})
                
                print(f"Successo: {filename} -> {mat_filename}")
                
            except Exception as e:
                print(f"Errore durante la conversione di {filename}: {e}")

if __name__ == '__main__':
    percorso_origine = "C:\\Users\\IRISc\\passive_bci_imsi\\custom_dataset\\iannicelli_2026\\"
    percorso_destinazione = "C:\\Users\\IRISc\\passive_bci_imsi\\custom_dataset_mat\\"
    
    convert_all_csv_to_mat(percorso_origine, percorso_destinazione)