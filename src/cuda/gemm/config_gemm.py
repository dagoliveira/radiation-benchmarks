#!/usr/bin/python3

import configparser
import copy
import os
import sys

sys.path.append("../../include")
from common_config import discover_board, execute_and_write_json_to_file

ALPHA = 1.0
BETA = 0.0
SIZES = [8192]
PRECISIONS = ["float"]  # , "half"]
ITERATIONS = 10000000
USE_TENSOR_CORES = [False]
USE_CUBLAS = [False]
MEMTMR = False

COMPILER_VERSION = [
    # ("10.1", "g++"),
    ("7.0", "g++-4.8")
]

COMPILER_FLAGS = (
    # append to parameter list the number of the registers
    '--maxrregcount=16',

    # Enable (disable) to allow compiler to perform expensive optimizations
    # using maximum available resources (memory and compile-time).
    # '"-Xptxas --allow-expensive-optimizations=false"',

    # # Fast math implies --ftz=true --prec-div=false --prec-sqrt=false --fmad=true.
    "--use_fast_math",
)


def config(device, compiler, debug):
    benchmark_bin = "gemm"
    cuda_version = compiler[0]
    cxx_version = compiler[1]
    new_bench_bin = f"{benchmark_bin}_{cuda_version}"
    print(f"Generating {benchmark_bin} for CUDA, board:{device}")

    conf_file = '/etc/radiation-benchmarks.conf'
    try:
        config = configparser.RawConfigParser()
        config.read(conf_file)
        install_dir = config.get('DEFAULT', 'installdir') + "/"

    except IOError as e:
        raise IOError("Configuration setup error: " + str(e))

    data_path = install_dir + "data/gemm"
    bin_path = install_dir + "bin"
    src_benchmark = install_dir + "src/cuda/gemm"

    if not os.path.isdir(data_path):
        os.mkdir(data_path, 0o777)
        os.chmod(data_path, 0o777)

    generate = [f"sudo mkdir -p {bin_path}",
                f"cd {src_benchmark}",
                "make -C ../../include ",
                "mkdir -p " + data_path,
                f"sudo rm -f {data_path}/*{benchmark_bin}*",
                ]
    execute = []

    # gen only for max size, defined on cuda_trip_mxm.cu
    for precision in PRECISIONS:
        for size in SIZES:
            for use_tensor_cores in USE_TENSOR_CORES:
                for cublas in USE_CUBLAS:
                    for flags in COMPILER_FLAGS:
                        new_binary = f"{bin_path}/{new_bench_bin}"
                        cuda_path = f"/usr/local/cuda-{cuda_version}"
                        gen = [
                            [f'sudo env LD_LIBRARY_PATH={cuda_path}/'
                             'lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} ',
                             f"{new_binary}"],
                            [f'--size {size}'],
                            [f'--alpha {ALPHA} --beta {BETA}'],
                            [f'--input_a {data_path}/A_size_{size}_precision_{precision}.matrix'],
                            [f'--input_b {data_path}/B_size_{size}_precision_{precision}.matrix'],
                            [f'--input_c {data_path}/C_size_{size}_precision_{precision}.matrix'],
                            [f'--gold {data_path}/GOLD_size_{size}_tensor_{use_tensor_cores}'
                             f'_cublas_{cublas}_precision_{precision}.matrix'],
                            [f'--tensor_cores' if use_tensor_cores else ''],
                            [f'--precision {precision}'],
                            ['--use_cublas' if cublas else ''],
                            [f'--iterations {ITERATIONS}'],
                            ['--triplicated' if MEMTMR else ''],
                        ]

                        # change mode and iterations for exe
                        exe = copy.deepcopy(gen)
                        gen.append(['--generate'])
                        gen.append(['--check_input_existence'])
                        gen.append(['--verbose'])
                        variable_gen = ["make clean",
                                        f"make -j 4 LOGS=1 NVCCOPTFLAGS={flags} CXX={cxx_version} CUDAPATH={cuda_path}",
                                        f"sudo mv -f ./{benchmark_bin} {new_binary}"
                                        ]

                        generate.extend(variable_gen)
                        generate.append(' '.join(str(r) for v in gen for r in v))
                        execute.append(' '.join(str(r) for v in exe for r in v))

    execute_and_write_json_to_file(execute, generate, install_dir, new_bench_bin, debug=debug)


if __name__ == "__main__":
    debug_mode = False
    try:
        parameter = str(sys.argv[-1]).upper()

        if parameter == 'DEBUG':
            debug_mode = True
    except IndexError:
        debug_mode = False

    board, _ = discover_board()
    for compiler in COMPILER_VERSION:
        config(device=board, compiler=compiler, debug=debug_mode)
