/*
 * no_tensor_kernels.h
 *
 *  Created on: 28/10/2019
 *      Author: fernando
 */

#ifndef NO_TENSOR_KERNELS_H_
#define NO_TENSOR_KERNELS_H_

//__device__ volatile float t = 1;

template<const uint32_t COUNT, typename half_t, typename real_t>
__global__ void matrix_mult_kernel_dmr( //Kernel hardening
		real_t *A,   //A
		real_t *B,   //B
		real_t *C,   //C
		real_t *D_r, //D
		half_t *D_h, //D hardening
		real_t alpha, real_t beta, int wA, int wB, const uint32_t threshold) {
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
	volatile real_t Csub_real = 0;
	volatile half_t Csub_half = 0;

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
			volatile real_t ar = As[ty][k];
			volatile real_t br = Bs[k][tx];
			volatile half_t ah = As[ty][k];
			volatile half_t bh = Bs[k][tx];

			Csub_real += ar * br;
			Csub_half += ah * bh;

			if ((k % COUNT) == 0) {
				check_relative_error(Csub_half, Csub_real, threshold);
			}
		}

		// Synchronize to make sure that the preceding
		// computation is done before loading two new
		// sub-matrices of A and B in the next iteration
		__syncthreads();
	}

	// Write the block sub-matrix to device memory;
	// each thread writes one element
	const int index = wB * BLOCK_SIZE * by + BLOCK_SIZE * bx + wB * ty + tx;

	volatile real_t real_val = alpha * Csub_real + beta * C[index];
	volatile half_t half_val = half_t(alpha) * Csub_half
			+ half_t(beta) * half_t(C[index]);
	D_r[index] = real_val;
	D_h[index] = half_val;
	check_relative_error(half_val, real_val, threshold);
}

template<typename real_t>
__global__ void matrix_mult_kernel_unhardened(	//Kernel without hardening
		real_t *A,  //A
		real_t *B,  //B
		real_t *C,  //C
		real_t *D,  //D
		real_t alpha, real_t beta, int wA, int wB) {
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
			Csub = fma_inline(As[ty][k], Bs[k][tx], Csub);
		}

		// Synchronize to make sure that the preceding
		// computation is done before loading two new
		// sub-matrices of A and B in the next iteration
		__syncthreads();
	}

	// Write the block sub-matrix to device memory;
	// each thread writes one element
	const int index = wB * BLOCK_SIZE * by + BLOCK_SIZE * bx + wB * ty + tx;
	D[index] = alpha * Csub + beta * C[index];
}

#endif /* NO_TENSOR_KERNELS_H_ */
