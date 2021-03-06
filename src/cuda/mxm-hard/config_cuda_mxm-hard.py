#!/usr/bin/python

import ConfigParser
import copy
import os
import sys

sys.path.insert(0, '../../include')
from common_config import discover_board, execute_and_write_json_to_file

SIZES = [4096]
PRECISIONS = ["single"]
ITERATIONS = 10000
HARDENING = [0, 1]


def config(board, arith_type, hardening, debug):

    DATA_PATH_BASE = "mxm-hard_" + arith_type

    if hardening:
        benchmark_bin = "cuda_mxm-hard_" + arith_type
    else:
        benchmark_bin = "cuda_mxm-unhard_" + arith_type

    print "Generating " + benchmark_bin + " for CUDA, board:" + board

    conf_file = '/etc/radiation-benchmarks.conf'
    try:
        config = ConfigParser.RawConfigParser()
        config.read(conf_file)
        install_dir = config.get('DEFAULT', 'installdir') + "/"

    except IOError as e:
        print >> sys.stderr, "Configuration setup error: " + str(e)
        sys.exit(1)

    data_path = install_dir + "data/" + DATA_PATH_BASE
    bin_path = install_dir + "bin"
    src_benchmark = install_dir + "src/cuda/mxm-hard"

    if not os.path.isdir(data_path):
        os.mkdir(data_path, 0777)
        os.chmod(data_path, 0777)

    generate = ["sudo mkdir -p " + bin_path, 
                "cd " + src_benchmark, 
                "make clean", 
                "make -C ../../include ", 
                "make PRECISION=" + arith_type + " -j 4",
                "mkdir -p " + data_path, 
                "sudo rm -f " + data_path + "/*" + benchmark_bin + "*",
                "sudo mv -f ./" + benchmark_bin + " " + bin_path + "/"]
    execute = []

    # gen only for max size, defined on cuda_mxm-hard.cu
    max_size = 8192
    for i in SIZES:
        input_file = data_path + "/"

        gen = [None] * 7
        gen[0] = ['sudo env LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}} ', bin_path + "/" + benchmark_bin + " "]
        gen[1] = ['-size=' + str(i)]
        gen[2] = ['-input_a=' + input_file + 'A_' + str(max_size) + "_hardening_" + str(hardening) + '.matrix']
        gen[3] = ['-input_b=' + input_file + 'B_' + str(max_size) + "_hardening_" + str(hardening) + '.matrix']
        gen[4] = ['-gold=' + input_file + "GOLD_" +  str(i) + "_hardening_" + str(hardening) + ".matrix"]  # change for execute
        gen[5] = []
        gen[6] = ['-generate']

        # change mode and iterations for exe
        exe = copy.deepcopy(gen)
        exe[0][1] = bin_path + '/' + benchmark_bin + " "
        exe[5] = ['-iterations=' + str(ITERATIONS)]
        exe[6] = []

        generate.append(' '.join(str(r) for v in gen for r in v))
        execute.append(' '.join(str(r) for v in exe for r in v))

    execute_and_write_json_to_file(execute, generate, install_dir, benchmark_bin, debug=debug)



if __name__ == "__main__":
    try:
        parameter = str(sys.argv[1:][1]).upper() 
        if parameter == 'DEBUG':
            debug_mode = True
    except:
        debug_mode = False
    
    board, _ = discover_board()
    for p in PRECISIONS:
        for h in HARDENING:
            config(board=board, arith_type=p, hardening=h, debug=debug_mode)
    print "Multiple jsons may have been generated."
