import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

def scatter_with_regression(n, vector):
    """
    Genera uno scatter plot delle osservazioni nel tempo e vi sovrappone 
    la retta di regressione lineare.
    
    Parametri:
    n (str/int): Identificativo del segnale.
    vector (array-like): Vettore delle osservazioni (campionate a 250 Hz).
    
    Ritorna:
    tuple: (pendenza, intercetta) della retta di regressione.
    """
    fs = 250.0
    t = np.arange(len(vector)) / fs
    
    # Calcolo della retta di regressione lineare (polinomio di grado 1)
    # np.polyfit restituisce [pendenza, intercetta]
    slope, intercept = np.polyfit(t, vector, 1)
    regression_line = slope * t + intercept
    
    plt.figure(figsize=(10, 5))
    
    # Scatter plot dei dati grezzi
    plt.scatter(t, vector, alpha=0.5, s=10, label='Osservazioni', color='blue')
    
    # Plot della retta di regressione
    plt.plot(t, regression_line, color='red', linewidth=2, 
             label=f'Retta di regressione (y = {slope:.4f}x + {intercept:.4f})')
    
    # Formattazione
    plt.title(f'Scatter Plot e Regressione Lineare | Segnale {n}')
    plt.xlabel('Tempo (s)')
    plt.ylabel('Ampiezza')
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.legend()
    plt.tight_layout()
    plt.show()
    
    return slope, intercept

# Esempio d'uso
if __name__ == "__main__":
    matrice_np = pd.read_csv('vector_data\\TBR\\UnicornRecorder_14_05_2026_12_17_020.csv', header=None).to_numpy()
    print(np.shape(matrice_np))
    vettore_np = matrice_np.flatten()
    pendenza, intercetta = scatter_with_regression(1, vettore_np)