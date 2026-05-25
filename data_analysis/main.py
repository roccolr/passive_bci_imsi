from python_lib import scatter_with_regression
from pathlib import Path

if __name__ == '__main__':
    output_path = "C:\\Users\\Flexo Rodriguez\\Desktop\\data_mining_alfonso"
    base_input_path = "vector_data"
    types = ["TBR", "EI"]
    tau_map = dict()
    
    for type in types:
        directory = Path(base_input_path+f"\\{type}\\")
        tau_map[type] = []
        i = 0
        for file in directory.iterdir():
            if file.is_file():
                input_path = base_input_path+f"\\{type}\\"
                input_path = input_path + file.name
                print(f"processing {input_path}\tinto\t{output_path}")
                tau = scatter_with_regression.scatter_with_regression(i, input_path, type, output_path)
                tau_map[type].append(tau)
                i+=1

print(tau_map)