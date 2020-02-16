
#include <vector>
#include <iostream>

#include "cuda_utils.h"

// create both matrix and right hand side, Ke Wang 2013/08/12 11:51:06
/**
 * Benchmark from rodinia benchmark suite,
 *  updated for radiation benchmarks by Fernando (fernandofernandesantos@gmail.com) 2020
 */

#include "utils.h"

template<typename real_t>
void create_matrix(std::vector<real_t>& m) {
	int i, j;
	real_t lamda = -0.01;
	auto size = m.size();
	std::vector<real_t> coe(2 * size - 1);
	real_t coe_i = 0.0;

	for (i = 0; i < size; i++) {
		coe_i = 10 * exp(lamda * i);
		j = size - 1 + i;
		coe[j] = coe_i;
		j = size - 1 - i;
		coe[j] = coe_i;
	}

	for (i = 0; i < size; i++) {
		for (j = 0; j < size; j++) {
			m[i * size + j] = coe[size - 1 - i + j];
		}
	}

}

int main(int argc, char *argv[]) {

	int Size = 1024;
	int matrix_size = Size * Size;
	std::vector<float> a(matrix_size), b(matrix_size), finalVec(Size), m(matrix_size);
	FILE *fp;
	float totalKernelTime = 0;

	printf("WG size of kernel 1 = %d, WG size of kernel 2= %d X %d\n",
	MAXBLOCKSIZE, BLOCK_SIZE_XY, BLOCK_SIZE_XY);
	int verbose = 1;
	char flag;

	create_matrix(a);
	for (int j = 0; j < Size; j++)
		b[j] = 1.0;

	//InitProblemOnce(filename);
	for(auto& mi : m){
		mi = 0.0;
	}
	//begin timing
	auto time_start = rad::mysecond();

	// run kernels
	ForwardSub(m, a, b, Size, totalKernelTime);

	//end timing


	if (verbose) {
//		printf("Matrix m is: \n");
//		PrintMat(m, Size, Size, Size);
//
//		printf("Matrix a is: \n");
//		PrintMat(a, Size, Size, Size);
//
//		printf("Array b is: \n");
//		PrintAry(b, Size);
	}
	BackSub(finalVec, a, b, Size);
	if (verbose) {
		printf("The final solution is: \n");
//		PrintAry(finalVec, Size);
		for(auto i : finalVec)
			std::cout << i << " ";
		std::cout << std::endl;
	}

	auto time_end = rad::mysecond();

	std::cout << "Time total (including memory transfers) " << (time_end - time_start) << "s\n";
	std::cout << "Time for CUDA kernels: " << totalKernelTime << "s\n";
}