/*
 * device_funtions.h
 *
 *  Created on: 29/09/2019
 *      Author: fernando
 */

#ifndef DEVICE_FUNTIONS_H_
#define DEVICE_FUNTIONS_H_

#include "cuda_fp16.h"
#include "common.h"

#define THRESHOLD_SIZE 8000

__device__ unsigned long long errors;
//__device__ uint32_t thresholds[THRESHOLD_SIZE] = { 0 };

/**
 * EXP
 */
__DEVICE_INLINE__
half exp__(half lhs) {
#if __CUDA_ARCH__ >= 600
	return hexp(lhs);
#else
	return expf(float(lhs));
#endif
}

__DEVICE_INLINE__
float exp__(float lhs) {
	return expf(lhs);
}

__DEVICE_INLINE__
double exp__(double lhs) {
	return exp(lhs);
}

__DEVICE_INLINE__
void check_bit_error(float& lhs, double& rhs, const uint32_t threshold) {
	float rhs_float = float(rhs);
	uint32_t rhs_data = *((uint32_t*) (&rhs_float));
	uint32_t lhs_data = *((uint32_t*) (&lhs));
	uint32_t sub_res = SUB_ABS(lhs_data, rhs_data);
	float float_threshold = *((float*) (&threshold));
	if (fabs(lhs - rhs_float) > float_threshold) {
		printf("LHS %e RHS %e U %e\n", lhs, rhs, fabs(lhs - rhs_float));
		atomicAdd(&errors, 1);
	}
	lhs = rhs_float;
}

__DEVICE_INLINE__
void check_bit_error(FOUR_VECTOR<float>& lhs, FOUR_VECTOR<double>& rhs, const uint32_t threshold) {
	//CHECK each one of the coordinates
	check_bit_error(lhs.v, rhs.v, threshold);
	check_bit_error(lhs.x, rhs.x, threshold);
	check_bit_error(lhs.y, rhs.y, threshold);
	check_bit_error(lhs.z, rhs.z, threshold);
	lhs = rhs;
}

template<typename real_t> __DEVICE_INLINE__
void check_bit_error(real_t& lhs, real_t& rhs, const uint32_t threshold = 0) {
	if (lhs != rhs) {
		atomicAdd(&errors, 1);
	}
	lhs = rhs;
}

inline uint64_t get_dmr_error() {
	uint64_t dmr_errors;
	rad::checkFrameworkErrors(
			cudaMemcpyFromSymbol(&dmr_errors, errors, sizeof(uint64_t), 0,
					cudaMemcpyDeviceToHost));

	const uint64_t zero_value = 0;
	rad::checkFrameworkErrors(
			cudaMemcpyToSymbol(errors, &zero_value, sizeof(uint64_t), 0,
					cudaMemcpyHostToDevice));
	return dmr_errors;
}

#endif /* DEVICE_FUNTIONS_H_ */
