/*
 * dmr_nonconstant_kernels.h
 *
 *  Created on: Jul 30, 2019
 *      Author: fernando
 */

#ifndef DMR_NONCONSTANT_KERNELS_H_
#define DMR_NONCONSTANT_KERNELS_H_

#include <assert.h>

#include "Parameters.h"
#include "device_functions.h"

template<typename half_t, typename real_t>
__global__ void MicroBenchmarkKernel_ADDNONCONSTANT(real_t* input,
		real_t* output_real_t, real_t* threshold_out, half_t* output_half_t,
		int num_op) {
	int thread_id = blockIdx.x * blockDim.x + threadIdx.x;

	register real_t acc_real_t = 0.0;
	register half_t acc_half_t = 0.0;

	register real_t this_thread_input_real_t = input[thread_id];
	register half_t this_thread_input_half_t = half_t(input[thread_id]);
	register real_t threshold;
	for (int count = 0; count < OPS; count++) {
		acc_real_t = add_dmr(this_thread_input_real_t, acc_real_t);
		acc_half_t = add_dmr(this_thread_input_half_t, acc_half_t);

		if ((count % num_op) == 0) {
			threshold = acc_real_t - real_t(acc_half_t);
			check_bit_error(acc_half_t, acc_real_t);
			acc_half_t = half_t(acc_real_t);
		}
	}

	output_real_t[thread_id] = acc_real_t;
	output_half_t[thread_id] = acc_half_t;
	threshold_out[thread_id] = fabs(threshold);
}

template<typename half_t, typename real_t>
__global__ void MicroBenchmarkKernel_MULNONCONSTANT(real_t* input,
		real_t* output_real_t, real_t* threshold_out, half_t* output_half_t,
		int num_op) {
	int thread_id = blockIdx.x * blockDim.x + threadIdx.x;

	register real_t this_thread_input_real_t = input[thread_id];
	register half_t this_thread_input_half_t = half_t(input[thread_id]);

	register real_t acc_real_t = this_thread_input_real_t;
	register half_t acc_half_t = this_thread_input_half_t;

	register real_t threshold;
	for (int count = 0; count < OPS; count++) {
		acc_real_t = mul_dmr(this_thread_input_real_t, acc_real_t);
		acc_half_t = mul_dmr(this_thread_input_half_t, acc_half_t);

		if ((count % num_op) == 0) {
			threshold = acc_real_t - real_t(acc_half_t);
			check_bit_error(acc_half_t, acc_real_t);
			acc_half_t = half_t(acc_real_t);
		}
	}
	output_real_t[thread_id] = acc_real_t;
	output_half_t[thread_id] = acc_half_t;
	threshold_out[thread_id] = fabs(threshold);
}

template<typename half_t, typename real_t>
__global__ void MicroBenchmarkKernel_FMANONCONSTANT(real_t* input,
		real_t* output_real_t, real_t* threshold_out, half_t* output_half_t,
		int num_op) {
	int thread_id = blockIdx.x * blockDim.x + threadIdx.x;
	register real_t this_thread_input_real_t = input[thread_id];
	register half_t this_thread_input_half_t = half_t(input[thread_id]);

	register real_t acc_real_t = this_thread_input_real_t;
	register half_t acc_half_t = this_thread_input_half_t;

	register real_t threshold;
	for (int count = 0; count < OPS; count++) {
		acc_real_t = fma_dmr(this_thread_input_real_t, this_thread_input_real_t,
				acc_real_t);
		acc_half_t = fma_dmr(this_thread_input_half_t, this_thread_input_half_t,
				acc_half_t);

		if ((count % num_op) == 0) {
			threshold = acc_real_t - real_t(acc_half_t);
			check_bit_error(acc_half_t, acc_real_t);
			acc_half_t = half_t(acc_real_t);
		}
	}
	output_real_t[thread_id] = acc_real_t;
	output_half_t[thread_id] = acc_half_t;
	threshold_out[thread_id] = fabs(threshold);
}

#endif /* DMR_NONCONSTANT_KERNELS_H_ */