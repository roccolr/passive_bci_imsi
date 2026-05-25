from python_lib import trend_extractor, scatter_with_regression
from pathlib import Path

if __name__ == '__main__':
    output_path = "C:\\Users\\Flexo Rodriguez\\Desktop\\data_mining_alfonso"
    base_input_path = "vector_data"
    types = ["TBR", "EI"]

    for type in types:
        input_path = base_input_path+f"\\{type}\\"
        directory = Path(input_path)
        i = 0
        for file in directory.iterdir():
            if file.is_file():
                scatter_with_regression.scatter_with_regression(i, input_path, type, output_path)
