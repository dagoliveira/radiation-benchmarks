/*
 * micro_ldst_branch_kernels.cu
 *
 *  Created on: Mar 15, 2020
 *      Author: fernando
 */

#include "MicroLDST.h"
#include "utils.h"
#include "common.h"

template<uint32_t UNROLL_MAX, typename int_t> __forceinline__
__device__ void ldst_same_direction_kernel(int_t *dst, int_t *src) {
#pragma unroll UNROLL_MAX
	for (uint32_t i = 0; i < UNROLL_MAX; i++) {
		dst[i] = src[i];
	}
}

template<uint32_t MAX_MOVEMENTS, typename int_t>
__global__ void int_ldst_kernel(int_t* src, int_t* dst, uint32_t op) {
	const uint32_t thread_id = (blockIdx.x * blockDim.x + threadIdx.x) * op;
	int_t* dst_ptr = dst + thread_id;
	int_t* src_ptr = src + thread_id;

#pragma unroll MAX_MOVEMENTS
	for (uint32_t i = 0; i < MAX_MOVEMENTS; i++) {
		//copy to dst
		ldst_same_direction_kernel<MEM_OPERATION_NUM>(dst_ptr, src_ptr);
	}
}

template<typename int_t>
void execute_kernel(MICROINSTRUCTION& micro, int_t* input, int_t* output,
		uint32_t grid_size, uint32_t block_size, uint32_t operation_num) {
	int_ldst_kernel<MAX_THREAD_LD_ST_OPERATIONS> <<<grid_size, block_size>>>(
			input, output, operation_num);
}

template<>
void MicroLDST<int32_t>::execute_micro() {
	execute_kernel(this->parameters.micro, this->input_device.data(),
			this->output_device_1.data(), this->grid_size, this->block_size,
			this->parameters.operation_num);
}

