import numpy as np
from scipy import stats
import pandas as pd 

def extract_sen_slope(vector, fs=250.0):
    """
    Calcola la pendenza (slope) di un trend utilizzando lo stimatore di Theil-Sen.
    
    Parametri:
    vector (np.ndarray): Vettore monodimensionale delle osservazioni.
    fs (float): Frequenza di campionamento per scalare il tempo (default 250 Hz).
    
    Ritorna:
    float: Il valore della pendenza del trend (slope).
    """
    # Generazione dell'asse dei tempi in secondi
    t = np.arange(len(vector)) / fs
    
    # La funzione restituisce: slope, intercept, lower_bound, upper_bound
    slope, intercept, lo_slope, up_slope = stats.theilslopes(vector, t)
    
    return slope


if __name__ == '__main__':
    matrice_np = pd.read_csv('vector_data\\TBR\\UnicornRecorder_14_05_2026_12_17_020.csv', header=None).to_numpy()
    print(np.shape(matrice_np))
    vettore_np = matrice_np.flatten()
    slope = extract_sen_slope(vettore_np)
    print(slope)