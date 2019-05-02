/*
 * device_vector.h
 *
 *  Created on: 27/03/2019
 *      Author: fernando
 */

#ifndef DEVICE_VECTOR_H_
#define DEVICE_VECTOR_H_


#include <vector>
#include "cuda_utils.h"

template<class T>
struct DeviceVector{
	T *data;
	bool allocated;
	size_t v_size;

	DeviceVector(){
		printf("%p\n", this->data);

		this->v_size = 0;
		this->allocated = false;
		this->data = nullptr;
	}

	DeviceVector(const DeviceVector<T>& b){
		printf("%p\n", this->data);

		this->v_size = b.v_size;
		checkFrameworkErrors(cudaMalloc(&this->data, sizeof(T) * this->v_size));
		this->allocated = true;
		checkFrameworkErrors(cudaMemcpy(this->data, b.data(), sizeof(T) * this->v_size, cudaMemcpyDeviceToDevice));
	}

	DeviceVector(size_t size){
		printf("%p\n", this->data);

		this->v_size = size;
		checkFrameworkErrors(cudaMalloc(&this->data, sizeof(T) * this->v_size));
		this->allocated = true;
	}

	virtual ~DeviceVector(){
		printf("%p\n", this->data);
		if(this->allocated){
			checkFrameworkErrors(cudaFree(this->data));
		}

		this->allocated = false;
		this->data = nullptr;
	}

	T& operator [](int i) const {
		return this->host_data[i];
	}

	DeviceVector<T>& operator=(const std::vector<T>& other) {
		if(this->v_size != other.size()){
			checkFrameworkErrors(cudaFree(this->data));
			this->allocated = false;
		}

		if (this->allocated == false) {
			this->v_size = other.size();
			checkFrameworkErrors(cudaMalloc(&this->data, sizeof(T) * this->v_size));
			this->allocated = true;
		}


		checkFrameworkErrors(cudaMemcpy(this->data, other.data(), sizeof(T) * this->v_size,
								cudaMemcpyHostToDevice));

		return *this;
	}


	std::vector<T> to_vector(){
		std::vector<T> ret(this->v_size);

		checkFrameworkErrors(cudaMemcpy(ret.data(), this->data, sizeof(T) * this->v_size, cudaMemcpyDeviceToHost));
		return ret;
	}

};


#endif /* DEVICE_VECTOR_H_ */
