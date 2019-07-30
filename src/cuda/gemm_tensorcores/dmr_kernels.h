/*
 * dmr_kernels.h
 *
 *  Created on: Jul 20, 2019
 *      Author: fernando
 */

#ifndef DMR_KERNELS_H_
#define DMR_KERNELS_H_

/**
 * Vamos comecar do zero
 * coloque aqui os codigos so dmr
 *
 */

#include "nondmr_kernels.h"
#include "device_functions.h"

template<class half_t, class real_t>
__global__ void sw_mxm_dmr_kernel(real_t *D_r, half_t *D_h, real_t *C,
		real_t *A, real_t *B, real_t alpha, real_t beta, int wA, int wB) {
	// Block index
	int bx = blockIdx.x;
	int by = blockIdx.y;

	// Thread index
	int tx = threadIdx.x;
	int ty = threadIdx.y;

	// Index of the first sub-matrix of A processed by the block
	int aBegin = wA * BLOCK_SIZE * by;

	// Index of the last sub-matrix of A processed by the block
	int aEnd = aBegin + wA - 1;

	// Step size used to iterate through the sub-matrices of A
	int aStep = BLOCK_SIZE;

	// Index of the first sub-matrix of B processed by the block
	int bBegin = BLOCK_SIZE * bx;

	// Step size used to iterate through the sub-matrices of B
	int bStep = BLOCK_SIZE * wB;

	// Csub is used to store the element of the block sub-matrix
	// that is computed by the thread
	real_t Csub = 0;

	half_t Csub_half = 0;
	double threshold = -2222;
	// Loop over all the sub-matrices of A and B
	// required to compute the block sub-matrix
	for (int a = aBegin, b = bBegin; a <= aEnd; a += aStep, b += bStep) {
		// Declaration of the shared memory array As used to
		// store the sub-matrix of A
		__shared__ real_t As[BLOCK_SIZE][BLOCK_SIZE];

		// Declaration of the shared memory array Bs used to
		// store the sub-matrix of B
		__shared__ real_t Bs[BLOCK_SIZE][BLOCK_SIZE];

		// Load the matrices from device memory
		// to shared memory; each thread loads
		// one element of each matrix
		As[ty][tx] = A[a + wA * ty + tx];
		Bs[ty][tx] = B[b + wB * ty + tx];

		// Synchronize to make sure the matrices are loaded
		__syncthreads();

		// Multiply the two matrices together;
		// each thread computes one element
		// of the block sub-matrix
#pragma unroll

		for (int k = 0; k < BLOCK_SIZE; ++k) {
//			Csub += As[ty][k] * Bs[k][tx];
//			Csub_half += half_t(As[ty][k]) * half_t(Bs[k][tx]);
			fma_dmr(As[ty][k], Bs[k][tx], Csub);
			fma_dmr(half_t(As[ty][k]), half_t(Bs[k][tx]), Csub_half);

#if CHECKBLOCK == 1
			check_relative_error(Csub_half, Csub);

			double diff = fabs(double(Csub) - double(Csub_half));
			threshold = fmax(threshold, diff);

			Csub_half = half_t(Csub);
//#elif CHECKBLOCK >= 1
//			if((k % CHECKBLOCK) == 0) {
//				check_relative_error(Csub_half, Csub);
//
//				double diff = fabs(double(Csub) - double(Csub_half));
//				threshold = fmax(threshold, diff);
//
//				Csub_half = half_t(Csub);
//			}
#endif

		}

		// Synchronize to make sure that the preceding
		// computation is done before loading two new
		// sub-matrices of A and B in the next iteration
		__syncthreads();
	}
	const int index = wB * BLOCK_SIZE * by + BLOCK_SIZE * bx + wB * ty + tx;

	const real_t d_r = alpha * Csub + beta * C[index];
	const half_t d_h = half_t(alpha) * Csub_half
			+ half_t(beta) * half_t(C[index]);

//#if CHECKBLOCK == 0
//	check_relative_error(d_h, d_r);
//	threshold = fabs(double(Csub) - double(Csub_half));
//#endif

	printf("%.20e\n", threshold);

// Write the block sub-matrix to device memory;
// each thread writes one element
	D_r[index] = d_r;
	D_h[index] = d_h;
}

#endif /* DMR_KERNELS_H_ */
