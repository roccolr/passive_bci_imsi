import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def kendall_extract(n, vector):
    """
    Calcola il tau di Kendall (corretto per i ties) tra un vettore di osservazioni 
    e il tempo, generando anche un plot.
    
    Parametri:
    n (str/int): Identificativo del segnale (usato nel plot).
    vector (array-like): Vettore delle osservazioni.
    
    Ritorna:
    float: Il valore del tau-b di Kendall.
    """
    # 1. Generazione del vettore tempo basato sul campionamento a 250 Hz
    fs = 250.0
    t = np.arange(len(vector)) / fs
    
    # 2. Creazione del DataFrame Pandas
    df = pd.DataFrame({
        'Tempo': t,
        'Osservazioni': vector
    })
    
    # 3. Calcolo del tau di Kendall. 
    # Pandas utilizza la variante Tau-b, che applica la correzione per i ties.
    tau = df['Tempo'].corr(df['Osservazioni'], method='kendall')
    
    # 4. Plot dei dati
    plt.figure(figsize=(10, 5))
    plt.plot(df['Tempo'], df['Osservazioni'], label=f'Segnale {n}', linewidth=1)
    
    # Formattazione del grafico
    plt.title(f'Analisi Segnale {n} | $\\tau$ di Kendall = {tau:.4f}')
    plt.xlabel('Tempo (s)')
    plt.ylabel('Ampiezza')
    plt.grid(True, linestyle='--', alpha=0.7)
    plt.legend()
    plt.tight_layout()
    plt.show()
    
    return tau

# Esempio d'uso
if __name__ == "__main__":
    # Generazione di un vettore di test (es. un trend lineare con rumore)
    np.random.seed(42)
    campioni = 1000
    vettore_test = np.linspace(0, 5, campioni) + np.random.normal(0, 2, campioni)
    
    tau_calcolato = kendall_extract(1, vettore_test)
    print(f"Tau calcolato: {tau_calcolato:.4f}")