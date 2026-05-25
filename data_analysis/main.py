from python_lib import scatter_with_regression
from pathlib import Path
from scipy import stats
import numpy as np


if __name__ == '__main__':
    output_path = "C:\\Users\\Flexo Rodriguez\\Desktop\\data_mining_alfonso"
    base_input_path = "vector_data"
    types = ["TBR", "EI"]
    tau_map = dict()
    verbose = False

    for type in types:
        directory = Path(base_input_path+f"\\{type}\\")
        tau_map[type] = []
        i = 0
        for file in directory.iterdir():
            if file.is_file():
                input_path = base_input_path+f"\\{type}\\"
                input_path = input_path + file.name
                if verbose == True:
                    print(f"processing {input_path}\tinto\t{output_path}")
                tau, pendenza, intercetta = scatter_with_regression.scatter_with_regression(i, input_path, type, output_path)
                tau_map[type].append(tau)
                i+=1

print(tau_map)

# TEST DI MAN KENDAL 

alpha = 0.5
z_alpha = 1.96

trovato = False 
for tau_v in tau_map["TBR"]:
    if np.abs(tau_v) > z_alpha:
        print("[ACCETTATA IPOTESI NULLA]\tTBR")
        trovato = True

if trovato == False:
    print("[RIFIUTATA IPOTESI NULLA]\tTBR")
trovato = False 

for tau_v in tau_map["EI"]:
    if np.abs(tau_v) > z_alpha:
        print("[ACCETTATA IPOTESI NULLA]\tEI")
        trovato = True

if trovato == False:
    print("[RIFIUTATA IPOTESI NULLA]\tEI")

# OUTPUT 
# [RIFIUTATA IPOTESI NULLA]       TBR
# [RIFIUTATA IPOTESI NULLA]       EI

# --- TEST DI WILCOXON --- 

# H0 -> La mediana dei tau è zero
# H1 -> La mediana dei tau è diversa da zero 

# res_TBR = stats.wilcoxon(tau_map["TBR"])
# res_EI = stats.wilcoxon(tau_map["EI"])

# if res_TBR.pvalue < 0.1:
#     print(f"[TBR] Significativo (p={res_TBR.pvalue:.3f}): la mediana dei tau è diversa da 0.")
# else:
#     print(f"[TBR] Non significativo (p={res_TBR.pvalue:.3f}).")

    
# if res_EI.pvalue < 0.1:
#     print(f"[EI] Significativo (p={res_TBR.pvalue:.3f}): la mediana dei tau è diversa da 0.")
# else:
#     print(f"[EI] Non significativo (p={res_EI.pvalue:.3f}).")


