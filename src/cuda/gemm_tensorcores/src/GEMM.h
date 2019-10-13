/*
 * GEMMWMMA.h
 *
 *  Created on: 12/08/2018
 *      Author: fernando
 */

#ifndef GEMM_H_
#define GEMM_H_

#include "GEMMBase.h"

#include "nondmr_kernels.h"
#include "dmr_kernels.h"

template<class real_t>
class GEMM: public GEMMBase<0, 0, real_t, real_t, real_t> {
public:

	GEMM(
			const std::vector<real_t>& host_a0, //Matrix A
			const std::vector<real_t>& host_b0, // MAtrix B
			const std::vector<real_t>&host_c0, // Matric C
			const std::vector<real_t>& host_d0, size_t k, real_t alpha,
			real_t beta) :
			GEMMBase<0, 0, real_t, real_t, real_t>(host_a0, host_b0, host_c0, host_d0,
					k, alpha, beta) {

	}
	void gemm() {
//		std::cout << this->grid_dim << std::endl;
//		std::cout << this->block_dim << std::endl;

		sw_mxm_kernel<<<this->grid_dim, this->block_dim>>>(
				this->device_ptr_d0.data(), this->device_ptr_c0.data(),
				this->device_ptr_a0.data(), this->device_ptr_b0.data(),
				this->alpha, this->beta, this->k, this->k);

		this->debug("sw_mxm device synchronize");
		rad::checkFrameworkErrors(cudaPeekAtLastError());

		rad::checkFrameworkErrors(cudaDeviceSynchronize());
	}
};

template<const uint32_t COUNT, const uint32_t THRESHOLD, class real_t, class mixed_t>
class GEMMDMRMIXED: public GEMMBase<COUNT, THRESHOLD, real_t, real_t, mixed_t> {
public:

	GEMMDMRMIXED(
			const std::vector<real_t>& host_a0, //Matrix A
			const std::vector<real_t>& host_b0, // MAtrix B
			const std::vector<real_t>&host_c0, // Matric C
			const std::vector<real_t>& host_d0, size_t k, real_t alpha,
			real_t beta) :
			GEMMBase<COUNT, THRESHOLD, real_t, real_t, mixed_t>(host_a0, host_b0, host_c0,
					host_d0, k, alpha, beta) {

	}

	void gemm() {
		this->device_is_memory_bad.clear();
		sw_mxm_dmr_kernel<COUNT, THRESHOLD> <<<this->grid_dim, this->block_dim>>>(
				this->device_ptr_d0.data(), this->device_ptr_mixed_dmr.data(),
				this->device_ptr_c0.data(), this->device_ptr_a0.data(),
				this->device_ptr_b0.data(), this->alpha, this->beta, this->k,
				this->k);

		this->debug("device synchronize");
		rad::checkFrameworkErrors(cudaPeekAtLastError());

		rad::checkFrameworkErrors(cudaDeviceSynchronize());

	}

};

template<const uint32_t COUNT, class real_t>
class GEMMDMR: public GEMMBase<COUNT, 0, real_t, real_t, real_t> {
public:

	GEMMDMR(
			const std::vector<real_t>& host_a0, //Matrix A
			const std::vector<real_t>& host_b0, // MAtrix B
			const std::vector<real_t>&host_c0, // Matric C
			const std::vector<real_t>& host_d0, size_t k, real_t alpha,
			real_t beta) :
			GEMMBase<COUNT, 0, real_t, real_t, real_t>(host_a0, host_b0, host_c0, host_d0,
					k, alpha, beta) {

	}

	void gemm() {
		this->device_is_memory_bad.clear();
		sw_mxm_dmr_kernel<COUNT, 0> <<<this->grid_dim, this->block_dim>>>(
				this->device_ptr_d0.data(), this->device_ptr_mixed_dmr.data(),
				this->device_ptr_c0.data(), this->device_ptr_a0.data(),
				this->device_ptr_b0.data(), this->alpha, this->beta, this->k,
				this->k);

		this->debug("device synchronize");
		rad::checkFrameworkErrors(cudaPeekAtLastError());

		rad::checkFrameworkErrors(cudaDeviceSynchronize());

		//end
	}
};

#endif /* GEMMWMMA_H_ */