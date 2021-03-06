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
 * Author: Yifan Sun (yifansun@coe.neu.edu)
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

#include <cstdlib>
#include <cstdio>
#include<cstring>
#include "kernels.h"
#include "fir_benchmark.h"

void FirBenchmark::Initialize() {
  numTap = 1024;
  numTotalData = numData * numBlocks;
  local = 64;

  input = new float[numTotalData];
  output = new float[numTotalData];
  coeff = new float[numTap];
  temp_output = new float[numData + numTap - 1];

  // Initialize input data
  for (unsigned int i = 0; i < numTotalData; i++) {
    input[i] = i;
  }

  // Initialize coefficient
  for (unsigned int i = 0; i < numTap; i++) {
    coeff[i] = 1.0 / numTap;
  }

  // Initialize temp output
  for (unsigned int i = 0; i < (numData + numTap - 1); i++) {
    temp_output[i] = 0.0;
  }

  // CKALRA, DLOWELL  
  ebsize = numData;
//  if (ebsize % BLOCK_SIZE != 0)
//   ebsize = (ebsize / BLOCK_SIZE + 1) * BLOCK_SIZE;
  errorBuffer = (unsigned int*)calloc(sizeof(unsigned int), ebsize);
}

void FirBenchmark::Run() {
  for (unsigned int i = 0; i < numBlocks; i++) {
    SNK_INIT_LPARM(lparm, 0);
    lparm->ndim = 1;
    lparm->gdims[0] = 2*numData;
    lparm->ldims[0] = 2*128;

		memset(errorBuffer, 0, ebsize*sizeof(unsigned int));
    FIR(output, coeff, temp_output, numTap, errorBuffer, lparm);
  }

  /* CKALRA, DLOWELL: Process errorBuffer, inthebeam test you can just save to file */
  unsigned int errCount = 0;
  unsigned int totErrCount = 0;
  printf("errorBuffer size (flat global size): %u\n",ebsize);
  for(unsigned int i=0;i<ebsize;i++){
    if(errorBuffer[i]>0){
      errCount++;
      totErrCount+=errorBuffer[i];
    }
  }
  printf("Threads with errors: %u\n",errCount);
  printf("Total errors: %u\n\n",totErrCount);
}

void FirBenchmark::Verify() {
  for (unsigned int i = 0; i < numTotalData; i++) {
    printf("output[i] = %f\n", output[i]);
  }
}

void FirBenchmark::Summarize() {
}

void FirBenchmark::Cleanup() {
  delete[] input;
  delete[] output;
  delete[] coeff;
  delete[] temp_output;
}
