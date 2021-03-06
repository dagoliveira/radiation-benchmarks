#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <string>
#include <omp.h>

#include "safe_memory.h"

#ifdef LOGS
#include "log_helper.h"
#endif
// The timestamp is updated on every log_helper function call.

#include <cublas_v2.h>

#include <cuda_fp16.h>
#include "half.hpp"

// helper functions
#include "helper_string.h"
#include "helper_cuda.h"

#undef min
#define min( x, y ) ( (x) < (y) ? (x) : (y) )
#undef max
#define max( x, y ) ( (x) > (y) ? (x) : (y) )

#define BLOCK_SIZE 32

#define DEFAULT_INPUT_SIZE 8192

int verbose = 0;
int fault_injection = 0;

int k = 0; // k x k matrix size
int iterations = 100000000; // global loop iteracion

//================== Input paths
char *gold_matrix_path, *a_matrix_path, *b_matrix_path;

FILE* f_A;
FILE* f_B;
FILE* f_GOLD;
//====================================

//================== Host and device matrix ptr's
half_float::half *A;
half_float::half *B;
half_float::half *C;
half_float::half *GOLD;

half *d_A;
half *d_B;
half *d_C;
//====================================

typedef char byte;

//================== cublas GEMM parameters
const half_float::half oneValue(1.0);
const half alpha = *((half*) &oneValue);
const half beta = *((half*) &oneValue);
cublasOperation_t transa = CUBLAS_OP_T;
cublasOperation_t transb = CUBLAS_OP_T;
int sizea, sizeb, sizec;

void GetDevice() {
//================== Retrieve and set the default CUDA device
	cudaDeviceProp prop;
	cudaError_t teste;
	int count = 0;
	teste = cudaGetDeviceCount(&count);
	printf("\nGet Device Test: %s\n", cudaGetErrorString(teste));
	for (int i = 0; i < count; i++) {
		cudaGetDeviceProperties(&prop, i);
		printf("Name: %s\n", prop.name);
	}
	int *ndevice;
	int dev = 0;
	ndevice = &dev;
	cudaGetDevice(ndevice);

	cudaSetDevice(0);
	cudaGetDeviceProperties(&prop, 0);
	printf("\ndevice: %d %s\n", *ndevice, prop.name);

}

double mysecond() {
	struct timeval tp;
	struct timezone tzp;
	int i = gettimeofday(&tp, &tzp);
	return ((double) tp.tv_sec + (double) tp.tv_usec * 1.e-6);
}

void allocCudaMemory() {
//================== CUDA error handlers
	cudaError_t malloc;
	const char *erro = 0;
//====================================
#ifdef SAFE_MALLOC
	d_A = (half*)safe_malloc(sizea * sizeof(half));
#else
	malloc = cudaMalloc((void**) &d_A, sizea * sizeof(half));
	if (strcmp(erro, "no error") != 0) {
#ifdef LOGS
		log_error_detail((char *)"error a"); end_log_file();
#endif
		exit (EXIT_FAILURE);
	} //mem allocate failure
#endif

#ifdef SAFE_MALLOC
	d_B = (half*)safe_malloc(sizeb * sizeof(half));
#else
	malloc = cudaMalloc((void**) &d_B, sizeb * sizeof(double));
	erro = cudaGetErrorString(malloc);
	if (strcmp(erro, "no error") != 0) {
#ifdef LOGS
		log_error_detail((char *)"error b"); end_log_file();
#endif
		exit (EXIT_FAILURE);
	} //mem allocate failure
#endif

#ifdef SAFE_MALLOC
	d_C = (half*)safe_malloc(sizec * sizeof(half));
#else
	malloc = cudaMalloc((void**) &d_C, sizec * sizeof(double));
	erro = cudaGetErrorString(malloc);

	if (strcmp(erro, "no error") != 0) {
#ifdef LOGS
		log_error_detail((char *)"error c"); end_log_file();
#endif
		exit (EXIT_FAILURE);
	} //mem allocate failure
#endif
}

void copyCudaMemory() {
//================== CUDA error handlers
	cudaError_t mcpy;
	const char *erro;
//====================================
	mcpy = cudaMemset(d_C, 0, sizea * sizeof(half));
	erro = cudaGetErrorString(mcpy);
	if (strcmp(erro, "no error") != 0) {
#ifdef LOGS
		log_error_detail((char *)"error gpu load c"); end_log_file();
#endif
		exit (EXIT_FAILURE);
	} //mem allocate failure

	mcpy = cudaMemcpy(d_A, A, sizeb * sizeof(half), cudaMemcpyHostToDevice); // PUSH A
	erro = cudaGetErrorString(mcpy);
	if (strcmp(erro, "no error") != 0) {
#ifdef LOGS
		log_error_detail((char *)"error gpu load b"); end_log_file();
#endif
		exit (EXIT_FAILURE);
	} //mem allocate failure

	mcpy = cudaMemcpy(d_B, B, sizeb * sizeof(half), cudaMemcpyHostToDevice); // PUSH B
	erro = cudaGetErrorString(mcpy);
	if (strcmp(erro, "no error") != 0) {
#ifdef LOGS
		log_error_detail((char *)"error gpu load b"); end_log_file();
#endif
		exit (EXIT_FAILURE);
	} //mem allocate failure
}

void ReadMatrixFromFile() {
//================== Read inputs to HOST memory
	int i;
	double time = mysecond();
	f_A = fopen(a_matrix_path, "rb");
	f_B = fopen(b_matrix_path, "rb");
	f_GOLD = fopen(gold_matrix_path, "rb");
	if (!(f_A && f_B && f_GOLD)) {
		printf("Cant open matrices.\n");
#ifdef LOGS
		log_error_detail((char *)"Cant open matrices"); end_log_file();
#endif
		exit(-3);
	}
	size_t ret_value[3];
	for (i = 0; i < k; i++) {
		ret_value[0] = fread(&A[k * i], sizeof(half) * k, 1, f_A);
		ret_value[1] = fread(&B[k * i], sizeof(half) * k, 1, f_B);
		ret_value[2] = fread(&GOLD[k * i], sizeof(half) * k, 1, f_GOLD);
		if (ret_value[0] != 1 || ret_value[1] != 1 || ret_value[2] != 1) {
			printf("Bad input/gold formatting: %lu ; %lu ; %lu .\n",
					ret_value[0], ret_value[1], ret_value[2]);
#ifdef LOGS
			log_error_detail((char *)"Bad input/gold formatting."); end_log_file();
#endif
			exit(-3);
		}
	}
	if (verbose)
		printf("Done reading matrices in %.2fs\n", mysecond() - time);

	fclose(f_A);
	fclose(f_B);
	fclose(f_GOLD);

	if (fault_injection) {
		half_float::half tempValue(0.5);
		A[3] = *((half_float::half*) &tempValue);
		printf("!! Injected forced value 0.5 on position A[3]\n");
	}
}

// bool badass_memcmp(half_float::half *gold, half_float::half *found, unsigned long n){
//      double result = 0.0;
//      int i;
//      unsigned long  chunk = ceil(float(n) / float(omp_get_max_threads()));
//      // printf("size %d max threads %d chunk %d\n", n, omp_get_max_threads(), chunk);
//      double time = mysecond();
// #pragma omp parallel for default(shared) private(i) schedule(static,chunk) reduction(+:result)
//    for (i=0; i < n; i++)
//      result = result + (gold[i] - found[i]);

//     //  printf("comparing took %lf seconds, diff %lf\n", mysecond() - time, result);
//      if (fabs(result) > 0.0000000001)
//              return true;
//      return false;
// }

bool badass_memcmp(byte *gold, byte *found, unsigned long n) {
	bool flag = false;
#pragma omp parallel for shared(flag)
	for (int i = 0; i < n; i++) {
		if (gold[i] != found[i]) {
			//printf("memcmp found an error at position [%d]: gold: 0x%hhX | output: 0x%hhX\n", i, gold[i], found[i]);
			flag = true;
		}
	}

	return flag;
}

bool badass_memcmp_half(half_float::half *gold, half_float::half *found,
		unsigned long n) {
	bool flag = false;
	double t = mysecond();
	double min = 1.0e-10;
#pragma omp parallel for shared(flag)
	for (unsigned long i = 0; i < n; i++) {
		half_float::half valGold = GOLD[i];
		half_float::half valOutput = C[i];
		if (fabs((valOutput - valGold) / valGold > min)
				|| fabs((valOutput - valGold) / valGold) > min) {
			//printf("memcmp found an error at position [%d]: gold: 0x%hhX | output: 0x%hhX\n", i, gold[i], found[i]);
			flag = true;
		}
	}

	double final_time = mysecond() - t;
	if (verbose)
		printf("Time comparing %lf\n", final_time);
	return flag;
}

// __device__ int kerrors;
//
// __global__ void GoldChkKernel (half *gk, half *ck, int n)//, int *kerrors)
// {
// //================== HW Accelerated output validation
//      int tx = blockIdx.x * BLOCK_SIZE + threadIdx.x;
//      int ty = blockIdx.y * BLOCK_SIZE + threadIdx.y;
//      //if ((fabs((gk[ty*n+tx]-ck[ty*n+tx])/gk[ty*n+tx]) > 0.0000000001)||(fabs((gk[ty*n+tx]-ck[ty*n+tx])/ck[ty*n+tx]) > 0.0000000001))
//      if (gk[ty*n + tx].x != ck[ty*n + tx].x)
//              atomicAdd(&kerrors, 1);
//
// }

int check_chunk_errors(half_float::half *ptr_c, half_float::half *ptr_gold,
		int start_i, int chunk_size) {
	int final_errors = 0;
	char error_detail[300];
	printf("Thread %d init\n", omp_get_thread_num());
	for (int i = start_i; i < (start_i + chunk_size); i++) {
		half_float::half val_gold = ptr_gold[i];
		half_float::half val_output = ptr_c[i];
		// if ((fabs((double)(valOutput-valGold)/valGold) > 1e-10)||(fabs((double)(val_output-val_gold)/valGold) > 1e-10)) {
		if (val_gold != val_output) {
//			std::string error_detail = std::string(
//					"p: [" + std::to_string((int) floor(i / k)) + ", "
//							+ std::to_string(i % k) + "], r: "
//							+ std::to_string(val_output) + ", e: "
//							+ std::to_string(val_gold));

			snprintf(error_detail, 150, "p: [%d, %d], r: %1.20e, e: %1.20e",
					(int) floor(i / k), i % k, (double) val_output,
					(double) val_gold);
			if (verbose && (final_errors < 10))
				printf("Thread %d %s\n", omp_get_thread_num(), error_detail);

#ifdef LOGS
#pragma omp critical
			{
				log_error_detail(error_detail);
			}
#endif
			final_errors++;

		}
	}
	printf("Thread %d finish\n", omp_get_thread_num());
	return final_errors;
}

void real_check_output_errors() {
	int host_errors = 0;
	int array_size = k * k;
	printf("ARRAY SIZE %d\n", array_size);

	double time_before = mysecond();
#pragma omp parallel
	{
		int max_threads = omp_get_num_threads();
		int chunk_size = ceil(float(array_size) / float(max_threads));
		printf("Max threads %d\n", max_threads);

#pragma omp for reduction(+:host_errors)
//#pragma omp parallel for shared(host_errors)
		for (int i = 0; i < max_threads; i++) {

			host_errors += check_chunk_errors(C, GOLD, i * chunk_size,
					chunk_size);
		}
	}
	printf("Time comparing %lf %d\n", mysecond() - time_before, host_errors);

	// printf("numErrors:%d", host_errors);

	/*if (host_errors != 0) {
	 printf("#");
	 #ifdef LOGS
	 log_error_count(host_errors);
	 #endif
	 //================== Release device memory to ensure there is no corrupted data on the inputs of the next iteration
	 cudaFree(d_A);
	 cudaFree(d_B);
	 cudaFree(d_C);
	 //====================================
	 ReadMatrixFromFile();
	 //================== Init DEVICE memory
	 allocCudaMemory();
	 copyCudaMemory();
	 //====================================
	 }*/
}

void checkOutputErrors() {
	int host_errors = 0;
	int array_size = k * k;
	char error_detail[150];

	double time_before = mysecond();
#pragma omp parallel for shared(host_errors)
	for (int i = 0; i < array_size; i++) {
		half_float::half valGold = GOLD[i];
		half_float::half valOutput = C[i];
		// if ((fabs((double)(valOutput-valGold)/valGold) > 1e-10)||(fabs((double)(valOutput-valGold)/valGold) > 1e-10)) {
		if (valGold != valOutput) {
#pragma omp critical
			{
				snprintf(error_detail, 150, "p: [%d, %d], r: %1.20e, e: %1.20e",
						(int) floor(i / k), i % k, (double) valOutput,
						(double) valGold);
				if (verbose && (host_errors < 10))
					printf("%s\n", error_detail);

#ifdef LOGS
				log_error_detail(error_detail);
#endif
				host_errors++;
			}
		}
	}
	printf("Time comparing %lf ", mysecond() - time_before);
//	real_check_output_errors();
	printf("numErrors:%d\n", host_errors);

	if (host_errors != 0) {
		printf("#");
#ifdef LOGS
		log_error_count(host_errors);
#endif
		//================== Release device memory to ensure there is no corrupted data on the inputs of the next iteration
		cudaFree(d_A);
		cudaFree(d_B);
		cudaFree(d_C);
		//====================================
		ReadMatrixFromFile();
		//================== Init DEVICE memory
		allocCudaMemory();
		copyCudaMemory();
		//====================================
	}
}

void usage() {
	printf(
			"Usage: cudaGemm -size=N [-input_a=<path>] [-input_b=<path>] [-gold=<path>] [-iterations=N] [-verbose] [-no-warmup] [-use_tensors=<0 or 1>]\n");
}

int main(int argc, char* argv[]) {
//================== Test vars
	int loop2;
	// int kernel_errors=0;
	// int zero = 0;
	double time;
	double kernel_time, global_time;
	double total_kernel_time, min_kernel_time, max_kernel_time;
	int device_warmup = 1;
	unsigned char use_tensor_cores = 0;
	// int gpu_check = 1;
//====================================

//================== Read test parameters
	if (argc < 2) {
		usage();
		exit(-1);
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "size")) {
		k = getCmdLineArgumentInt(argc, (const char **) argv, "size");

		if ((k <= 0) || (k % 16 != 0)) {
			printf("Invalid input size given on the command-line: %d\n", k);
			exit (EXIT_FAILURE);
		}
	} else {
		usage();
		exit (EXIT_FAILURE);
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "input_a")) {
		getCmdLineArgumentString(argc, (const char **) argv, "input_a",
				&a_matrix_path);
	} else {
		a_matrix_path = new char[100];
		snprintf(a_matrix_path, 100, "hgemm_a_%i.matrix",
				(signed int) DEFAULT_INPUT_SIZE);
		printf("Using default input_a path: %s\n", a_matrix_path);
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "input_b")) {
		getCmdLineArgumentString(argc, (const char **) argv, "input_b",
				&b_matrix_path);
	} else {
		b_matrix_path = new char[100];
		snprintf(b_matrix_path, 100, "hgemm_b_%i.matrix",
				(signed int) DEFAULT_INPUT_SIZE);
		printf("Using default input_a path: %s\n", b_matrix_path);
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "gold")) {
		getCmdLineArgumentString(argc, (const char **) argv, "gold",
				&gold_matrix_path);
	} else {
		gold_matrix_path = new char[100];
		snprintf(gold_matrix_path, 100, "hgemm_gold_%i.matrix", (signed int) k);
		printf("Using default gold path: %s\n", gold_matrix_path);
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "iterations")) {
		iterations = getCmdLineArgumentInt(argc, (const char **) argv,
				"iterations");
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "verbose")) {
		verbose = 1;
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "debug")) {
		fault_injection = 1;
		printf("!! Will be injected an input error\n");
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "no-warmup")) {
		device_warmup = 0;
		printf(
				"!! The first iteration may not reflect real timing information\n");
	}

	//flag for tensor cores
	if (checkCmdLineFlag(argc, (const char **) argv, "use_tensors")) {
		use_tensor_cores = getCmdLineArgumentInt(argc, (const char **) argv,
				"use_tensors");
	}
	// if (checkCmdLineFlag(argc, (const char **)argv, "no-gpu-gold-check"))
	// {
	//      gpu_check = 0;
	// } else {
	//     printf("!! The gold check will happen on the GPU and fall back to CPU in case of errors\n");
	// }
//====================================

//================== Set block and grid size for GoldChk kernel
	int gridsize = k / BLOCK_SIZE < 1 ? 1 : k / BLOCK_SIZE;
	int blocksize = k / BLOCK_SIZE < 1 ? k : BLOCK_SIZE;
	dim3 dimBlock(blocksize, blocksize);
	dim3 dimGrid(gridsize, gridsize);
//====================================

//================== Init logs
#ifdef LOGS
	char test_info[200];
	snprintf(test_info, 200, "size:%d type:half-precision use_tensor_cores:%d", k, use_tensor_cores);
	start_log_file((char *)"cudaHGEMM", test_info);
#endif
//====================================

//================== cublas GEMM parameters
	sizea = k * k;
	sizeb = k * k;
	sizec = k * k;
//====================================

//================== Alloc HOST memory
	A = (half_float::half*) malloc(sizea * sizeof(half));
	B = (half_float::half*) malloc(sizeb * sizeof(half));
	C = (half_float::half*) malloc(sizeb * sizeof(half));

	GOLD = (half_float::half*) malloc(sizec * sizeof(half));

	if (!(A && B && C && GOLD)) {
		printf("Failed on host malloc.\n");
		exit(-3);
	}
//====================================

//================== Init test environment
	// kernel_errors=0;
	total_kernel_time = 0;
	min_kernel_time = UINT_MAX;
	max_kernel_time = 0;
	GetDevice();
	ReadMatrixFromFile();
	cublasHandle_t cublasHandle;
	checkCudaErrors(cublasCreate(&cublasHandle));
	printf("cublasHGEMM\n");
	fflush (stdout);
//====================================
	printf("Tensor cores %d, is handle defined? %d\n", use_tensor_cores,
			(cublasHandle && true));
	//flag for tensor cores
	if (use_tensor_cores == 0) {
		cublasSetMathMode(cublasHandle, CUBLAS_DEFAULT_MATH);
	} else if (use_tensor_cores == 1) {
		cublasSetMathMode(cublasHandle, CUBLAS_TENSOR_OP_MATH);
	}

//================== Init DEVICE memory
	allocCudaMemory();
	copyCudaMemory();
//====================================

	for (loop2 = 0; loop2 < iterations; loop2++) { //================== Global test loop

		if (!loop2 && device_warmup)
			printf("First iteration: device warmup. Please wait...\n");

		// Timer...
		global_time = mysecond();

		cudaMemset(d_C, 0, sizea * sizeof(half));
		checkCudaErrors (cudaPeekAtLastError());checkCudaErrors
		(cudaDeviceSynchronize());
		checkCudaErrors(cudaPeekAtLastError());

		if (verbose)
			printf(",");

		kernel_time = mysecond();
#ifdef LOGS
		if (loop2 || !device_warmup)
		start_iteration();
#endif
		//================== Device computation, GEMM

		cublasHgemm(cublasHandle, transa, transb, k, k, k, &alpha, d_A, k, d_B,
				k, &beta, d_C, k);

		checkCudaErrors(cudaPeekAtLastError());
		checkCudaErrors(cudaDeviceSynchronize());
		checkCudaErrors(cudaPeekAtLastError());
		//====================================
#ifdef LOGS
		if (loop2 || !device_warmup)
		end_iteration();
#endif
		kernel_time = mysecond() - kernel_time;

		if (loop2 || !device_warmup) {
			total_kernel_time += kernel_time;
			min_kernel_time = min(min_kernel_time, kernel_time);
			max_kernel_time = max(max_kernel_time, kernel_time);
		}

		if (loop2 || !device_warmup)
			if (verbose)
				printf("Device kernel time for iteration %d: %.3fs\n", loop2,
						kernel_time);

		if (verbose)
			printf(",");

		// Timer...
		time = mysecond();

		// if (gpu_check) {
		//
		//      //================== Send GOLD to device, to perform HW output validation
		//      mcpy = cudaMemcpy(d_A, GOLD, sizea * sizeof( half ), cudaMemcpyHostToDevice );
		//      erro = cudaGetErrorString(mcpy);
		//      if(strcmp(erro, "no error") != 0) {
		//              printf("error mem load gold\n");
		//              #ifdef LOGS
		//              log_error_detail((char *)"error mem load gold"); end_log_file();
		//              #endif
		//              return 1;
		//      } //mem allocate failure
		//      cudaMemcpyToSymbol(kerrors, &zero, sizeof(int));
		//      //====================================
		//
		//      //================== Device computation, output validation
		//      GoldChkKernel<<<dimGrid,dimBlock>>>(d_A, d_C, k);
		//      cudaDeviceSynchronize();
		//      //====================================
		//
		//      //================== Retrieve output mismatchs
		//      kernel_errors=0;
		//      cudaMemcpyFromSymbol(&kernel_errors, kerrors, sizeof(unsigned int));
		//      //====================================
		//
		//     if (kernel_errors != 0) {
		//         printf(" kernel error: %d\n", kernel_errors);
		//
		//              mcpy = cudaMemcpy(A, d_C, sizec * sizeof( half ), cudaMemcpyDeviceToHost);
		//              erro = cudaGetErrorString(mcpy);
		//              if(strcmp(erro, "no error") != 0) {
		//                      #ifdef LOGS
		//                      log_error_detail((char *)"error mem down c"); end_log_file();
		//                      #endif
		//                      return 1;
		//              } //mem allocate failure
		//     }
		// }

		//================== If there are errors, check on host (increased reliability)

		// if (gpu_check == 0) {
		//     kernel_errors = 0;
		//     if (memcmp(A, GOLD, sizeof(half) * k*k)) {
		//         kernel_errors = 1;
		//     }
		// }

		//if (kernel_errors != 0) {
		if (loop2 || !device_warmup) {
			checkCudaErrors(
					cudaMemcpy(C, d_C, sizec * sizeof(half),
							cudaMemcpyDeviceToHost));
			checkCudaErrors(cudaDeviceSynchronize());
			checkCudaErrors(cudaPeekAtLastError());
			//~ if (memcmp(A, GOLD, sizeof(double) * k*k)) {
//            if (badass_memcmp_half(GOLD, C, sizec)) {
//                              printf("!");
			checkOutputErrors();
//              }
		}

		//====================================

		//================== Console hearthbeat
		/*if(kernel_errors > 0 || (loop2 % 10 == 0))
		 {
		 printf("test number: %d\n", loop2);
		 printf(" kernel time: %f\n", kernel_time);
		 }
		 else
		 {*/
		printf(".");
		fflush(stdout);
		//}
		//====================================

//              if (gpu_check) {
// //================== Send A back to the device
//              mcpy = cudaMemcpy(d_A, A, sizea * sizeof( half ), cudaMemcpyHostToDevice );
//              erro = cudaGetErrorString(mcpy);
//              if(strcmp(erro, "no error") != 0) {
//                      printf("error mem load A\n");
//                      #ifdef LOGS
//                      log_error_detail((char *)"error mem load A"); end_log_file();
//                      #endif
//                      return 1;
//              } //mem allocate failure
//===================================
		// }

		if (loop2 || !device_warmup)
			if (verbose)
				printf("Gold check time for iteration %d: %.3fs\n", loop2,
						mysecond() - time);

		if (loop2 || !device_warmup)
			if (verbose) {
				/////////// PERF
				double flops = 2.0 * (double) k * k * k;
				double gflops = flops / kernel_time;
				double outputpersec = (double) k * k / kernel_time;
				printf("SIZE:%d OUTPUT/S:%f FLOPS:%f (GFLOPS:%.2f)\n", k,
						outputpersec, gflops, gflops / 1000000000);
				///////////
			}

		if (loop2 || !device_warmup)
			if (verbose)
				printf("Iteration #%d time: %.3fs\n\n\n", loop2,
						mysecond() - global_time);
		fflush(stdout);
	}

	double gflops = 2.0 * (double) k * k * k / 1000000000; // Bilion FLoating-point OPerationS
	double averageKernelTime = total_kernel_time
			/ (iterations - (device_warmup ? 1 : 0));
	printf("\n-- END --\n"
			"Total kernel time: %.3fs\n"
			"Iterations: %d\n"
			"Average kernel time: %.3fs (best: %.3fs ; worst: %.3fs)\n"
			"Average GFLOPs: %.2f (best: %.2f ; worst: %.2f)\n",
			total_kernel_time, iterations, averageKernelTime, min_kernel_time,
			max_kernel_time, gflops / averageKernelTime,
			gflops / min_kernel_time, gflops / max_kernel_time);

	//================== Release device memory
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	//====================================

	free(A);
	free(B);
	free(C);
#ifdef LOGS
	end_log_file();
#endif

	return 0;
}
