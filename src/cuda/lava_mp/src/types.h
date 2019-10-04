/*
 * three_vector.h
 *
 *  Created on: 29/09/2019
 *      Author: fernando
 */

#ifndef THREE_VECTOR_H_
#define THREE_VECTOR_H_

#include <vector>
#include "device_vector.h"
#include "cuda_utils.h"

template<typename tested_type>
struct THREE_VECTOR {
	tested_type x, y, z;
};

template<typename tested_type>
struct FOUR_VECTOR {
	tested_type v, x, y, z;

	inline bool operator==(const FOUR_VECTOR& rhs) {
		return (this->x == rhs.x) && (this->y == rhs.y) && (this->z == rhs.z)
				&& (this->v == rhs.v);
	}

	inline bool operator!=(const FOUR_VECTOR& rhs) {
		return !(*this == rhs);
	}

	friend std::ostream& operator<<(std::ostream& os, const FOUR_VECTOR& lhs) {
		os << lhs.v;
		os << lhs.x;
		os << lhs.y;
		os << lhs.z;
		return os;
	}
};

template<typename tested_type>
struct par_str {
	tested_type alpha;
};

struct dim_str {
	// input arguments
	int cur_arg;
	int arch_arg;
	int cores_arg;
	int boxes1d_arg;
	// system memory
	long number_boxes;
	long box_mem;
	long space_elem;
	long space_mem;
	long space_mem2;
};

struct nei_str {
	// neighbor box
	int x, y, z;
	int number;
	long offset;
};

struct box_str {
	// home box
	int x, y, z;
	int number;
	long offset;
	// neighbor boxes
	int nn;
	nei_str nei[26];

	__host__ __device__ inline bool operator==(const box_str& rhs) {
		return (this->x == rhs.x) && (this->y == rhs.y) && (this->z == rhs.z)
				&& (this->number == rhs.number) && (this->offset == rhs.offset);
	}
	__host__ __device__ inline bool operator!=(const box_str& rhs) {
		return !(*this == rhs);
	}
};

template<typename T> using VectorOfDeviceVector = std::vector<rad::DeviceVector<T>>;

struct CudaStream {
	cudaStream_t stream;

	CudaStream() {
		rad::checkFrameworkErrors(
				cudaStreamCreateWithFlags(&this->stream,
						cudaStreamNonBlocking));
	}

	~CudaStream() {
		rad::checkFrameworkErrors(cudaStreamDestroy(this->stream));
	}

	void sync() {
		rad::checkFrameworkErrors(cudaStreamSynchronize(this->stream));
	}
};

#endif /* THREE_VECTOR_H_ */
