/*
 * Hetero-mark
 *
 * Copyright (c) 2015 Northeastern University
 * All rights reserved.
 *
 * Developed by:
 *   Northeastern University Computer Architecture Research (NUCAR) Group
 *   Northeastern University
 *   http://www.ece.neu.edu/groups/nucar/
 *
 * Author: Xiangyu Li (xili@ece.neu.edu)
 * Modified by: Yifan Sun (yifansun@coe.neu.edu)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal with the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 *   Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimers.
 *
 *   Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimers in the
 *   documentation and/or other materials provided with the distribution.
 *
 *   Neither the names of NUCAR, Northeastern University, nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this Software without specific prior written permission.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS WITH THE SOFTWARE.
 */

#ifndef SRC_HSA_MATMUL_HSA_MATMUL_BENCHMARK_H_
#define SRC_HSA_MATMUL_HSA_MATMUL_BENCHMARK_H_

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>

#include "src/common/benchmark/benchmark.h"
#include "src/hsa/matmul_hsa/kernels.h"

#define BLOCK_SIZE 22

 MatmulBenchmark : public Benchmark {
 private:
  void InitBuffer();
  void FillBuffer();
  void FillBufferCpu();
  void FillBufferGpu();
  void ExecKernel();

  void FreeBuffer();
  void ReadBuffer();

  int input_size;
  bool gen_inputs;

  size_t global_work_size[1];
  size_t local_work_size[1];
  int workGroupSize;
  int maxIter;

 public:
  PageRankBenchmark();

  void SetMatrixInputSize(int input_size) { this->input_size = input_size; }
  void SetGenInputs(bool g_inputs) { gen_inputs = g_inputs; }
  
  void Initialize() override;
  void Run() override;
  void Cleanup() override;
  void Verify() override;
  void Summarize() override;

  float abs(float value);

  void SaveGold();
  void CheckGold();
};

#endif  // SRC_HSA_MATMUL_HSA_MATMUL_BENCHMARK_H_
