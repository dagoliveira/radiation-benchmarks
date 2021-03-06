/*
 * device_functions.h
 *
 *  Created on: Mar 28, 2019
 *      Author: carol
 */

#ifndef DEVICE_FUNCTIONS_H_
#define DEVICE_FUNCTIONS_H_

__device__ unsigned long long errors = 0;

#define ZERO_FLOAT 0.000000207 ///3.0316488E-37 //1e-37
#define ZERO_HALF 4.166E-13 //1e-13

__device__ __forceinline__ double abs__(double a) {
	return fabs(a);
}

__device__ __forceinline__ float abs__(float a) {
	return fabsf(a);
}

__device__  __forceinline__ half abs__(half a) {
	return fabsf(a);
}

__device__ __forceinline__ void compare(const float lhs, const half rhs) {
	const float diff = abs__(lhs - float(rhs));
	const float zero = float(ZERO_HALF);
	if (diff > zero) {
		atomicAdd(&errors, 1);
	}
}

__device__ __forceinline__ void compare(const double lhs, const float rhs) {
	const double diff = abs__(lhs - double(rhs));
	const double zero = double(ZERO_FLOAT);
	if (diff > zero) {
		atomicAdd(&errors, 1);
	}
}

template<typename incomplete, typename full>
__device__ __forceinline__ void check_relative_error(incomplete acc_incomplete,
		full acc_full) {
	compare(acc_full, acc_incomplete);
}

template<typename T>
__device__ __forceinline__ void cast(volatile T& lhs, const T& rhs) {
	lhs = rhs;
}

/*
 * __float2half_rd  round-down mode
 * __float2half_rn round-to-nearest-even mode
 * __float2half_ru  round-up mode
 * __float2half_rz round-towards-zero mode
 */
__device__ __forceinline__ void cast(volatile half& lhs, const float& rhs) {
	lhs = __float2half_rn(rhs);
}

/*
 *__double2float_rd Convert a double to a float in round-down mode.
 *__double2float_rn Convert a double to a float in round-to-nearest-even mode.
 *__double2float_ru Convert a double to a float in round-up mode.
 *__double2float_rz Convert a double to a float in round-towards-zero mode.
 */
__device__ __forceinline__ void cast(volatile float& lhs, const double& rhs) {
	lhs = __double2float_rn(rhs);
}

/**
 * ----------------------------------------
 * FMA DMR
 * ----------------------------------------
 */

__device__ __forceinline__ double fma_dmr(double a, double b, double acc) {
	return __fma_rn(a, b, acc);
}

__device__ __forceinline__ float fma_dmr(float a, float b, float acc) {
	return __fmaf_rn(a, b, acc);
}

__device__  __forceinline__ half fma_dmr(half a, half b, half acc) {
//	return __hfma(a, b, acc);
#if __CUDA_ARCH__ >= 500
	return __hfma_sat(a, b, acc);
#else
	return __fmaf_rn(float(a), float(b), float(acc));
#endif
}

/**
 * ----------------------------------------
 * ADD DMR
 * ----------------------------------------
 */

__device__ __forceinline__ double add_dmr(double a, double b) {
	return __dadd_rn(a, b);
}

__device__ __forceinline__ float add_dmr(float a, float b) {
	return __fadd_rn(a, b);
}

__device__  __forceinline__ half add_dmr(half a, half b) {
	return __hadd(a, b);
}

/**
 * ----------------------------------------
 * MUL DMR
 * ----------------------------------------
 */

__device__ __forceinline__ double mul_dmr(double a, double b) {
	return __dmul_rn(a, b);
}

__device__ __forceinline__ float mul_dmr(float a, float b) {
	return __fmul_rn(a, b);
}

__device__  __forceinline__ half mul_dmr(half a, half b) {
#if __CUDA_ARCH__ >= 500
	return __hmul(a, b);
#else
	return __fmul_rn(float(a), float(b));
#endif

}

#endif /* DEVICE_FUNCTIONS_H_ */
