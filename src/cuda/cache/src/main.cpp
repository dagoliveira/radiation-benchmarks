/*
 ============================================================================
 Name        : main.cpp
 Author      : Fernando
 Version     :
 Copyright   : Your copyright notice
 Description : CUDA compute reciprocals
 ============================================================================
 */

#include "NVMLWrapper.h"
#include "kernels.h"

#include <cuda.h>
#include <cuda_runtime.h>
#include <helper_cuda.h>

void setup_for_kepler() {

}

void setup_for_volta() {

}

void get_device_information(int dev) {
	int driverVersion = 0, runtimeVersion = 0;
	cudaSetDevice(dev);
	cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp, dev);

	printf("\nDevice %d: \"%s\"\n", dev, deviceProp.name);

	// Console log
	cudaDriverGetVersion (&driverVersion);
	cudaRuntimeGetVersion (&runtimeVersion);
	printf("  CUDA Driver Version / Runtime Version          %d.%d / %d.%d\n",
			driverVersion / 1000, (driverVersion % 100) / 10,
			runtimeVersion / 1000, (runtimeVersion % 100) / 10);
	printf("  CUDA Capability Major/Minor version number:    %d.%d\n",
			deviceProp.major, deviceProp.minor);

	char msg[256];
#if defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)
	sprintf_s(msg, sizeof(msg),
			"  Total amount of global memory:                 %.0f MBytes "
			"(%llu bytes)\n",
			static_cast<float>(deviceProp.totalGlobalMem / 1048576.0f),
			(unsigned long long)deviceProp.totalGlobalMem);
#else
	snprintf(msg, sizeof(msg),
			"  Total amount of global memory:                 %.0f MBytes "
					"(%llu bytes)\n",
			static_cast<float>(deviceProp.totalGlobalMem / 1048576.0f),
			(unsigned long long) deviceProp.totalGlobalMem);
#endif
	printf("%s", msg);

	printf("  (%2d) Multiprocessors, (%3d) CUDA Cores/MP:     %d CUDA Cores\n",
			deviceProp.multiProcessorCount,
			_ConvertSMVer2Cores(deviceProp.major, deviceProp.minor),
			_ConvertSMVer2Cores(deviceProp.major, deviceProp.minor)
					* deviceProp.multiProcessorCount);
	printf("  GPU Max Clock rate:                            %.0f MHz (%0.2f "
			"GHz)\n", deviceProp.clockRate * 1e-3f,
			deviceProp.clockRate * 1e-6f);

#if CUDART_VERSION >= 5000
	// This is supported in CUDA 5.0 (runtime API device properties)
	printf("  Memory Clock rate:                             %.0f Mhz\n",
			deviceProp.memoryClockRate * 1e-3f);
	printf("  Memory Bus Width:                              %d-bit\n",
			deviceProp.memoryBusWidth);

	if (deviceProp.l2CacheSize) {
		printf("  L2 Cache Size:                                 %d bytes\n",
				deviceProp.l2CacheSize);
	}

#else
	// This only available in CUDA 4.0-4.2 (but these were only exposed in the
	// CUDA Driver API)
	int memoryClock;
	getCudaAttribute<int>(&memoryClock, CU_DEVICE_ATTRIBUTE_MEMORY_CLOCK_RATE,
			dev);
	printf("  Memory Clock rate:                             %.0f Mhz\n",
			memoryClock * 1e-3f);
	int memBusWidth;
	getCudaAttribute<int>(&memBusWidth,
			CU_DEVICE_ATTRIBUTE_GLOBAL_MEMORY_BUS_WIDTH, dev);
	printf("  Memory Bus Width:                              %d-bit\n",
			memBusWidth);
	int L2CacheSize;
	getCudaAttribute<int>(&L2CacheSize, CU_DEVICE_ATTRIBUTE_L2_CACHE_SIZE, dev);

	if (L2CacheSize) {
		printf("  L2 Cache Size:                                 %d bytes\n",
				L2CacheSize);
	}

#endif

	printf("  Maximum Texture Dimension Size (x,y,z)         1D=(%d), 2D=(%d, "
			"%d), 3D=(%d, %d, %d)\n", deviceProp.maxTexture1D,
			deviceProp.maxTexture2D[0], deviceProp.maxTexture2D[1],
			deviceProp.maxTexture3D[0], deviceProp.maxTexture3D[1],
			deviceProp.maxTexture3D[2]);
	printf(
			"  Maximum Layered 1D Texture Size, (num) layers  1D=(%d), %d layers\n",
			deviceProp.maxTexture1DLayered[0],
			deviceProp.maxTexture1DLayered[1]);
	printf("  Maximum Layered 2D Texture Size, (num) layers  2D=(%d, %d), %d "
			"layers\n", deviceProp.maxTexture2DLayered[0],
			deviceProp.maxTexture2DLayered[1],
			deviceProp.maxTexture2DLayered[2]);

	printf("  Total amount of constant memory:               %lu bytes\n",
			deviceProp.totalConstMem);
	printf("  Total amount of shared memory per block:       %lu bytes\n",
			deviceProp.sharedMemPerBlock);
	printf("  Total number of registers available per block: %d\n",
			deviceProp.regsPerBlock);
	printf("  Warp size:                                     %d\n",
			deviceProp.warpSize);
	printf("  Maximum number of threads per multiprocessor:  %d\n",
			deviceProp.maxThreadsPerMultiProcessor);
	printf("  Maximum number of threads per block:           %d\n",
			deviceProp.maxThreadsPerBlock);
	printf("  Max dimension size of a thread block (x,y,z): (%d, %d, %d)\n",
			deviceProp.maxThreadsDim[0], deviceProp.maxThreadsDim[1],
			deviceProp.maxThreadsDim[2]);
	printf("  Max dimension size of a grid size    (x,y,z): (%d, %d, %d)\n",
			deviceProp.maxGridSize[0], deviceProp.maxGridSize[1],
			deviceProp.maxGridSize[2]);
	printf("  Maximum memory pitch:                          %lu bytes\n",
			deviceProp.memPitch);
	printf("  Texture alignment:                             %lu bytes\n",
			deviceProp.textureAlignment);
	printf("  Concurrent copy and kernel execution:          %s with %d copy "
			"engine(s)\n", (deviceProp.deviceOverlap ? "Yes" : "No"),
			deviceProp.asyncEngineCount);
	printf("  Run time limit on kernels:                     %s\n",
			deviceProp.kernelExecTimeoutEnabled ? "Yes" : "No");
	printf("  Integrated GPU sharing Host Memory:            %s\n",
			deviceProp.integrated ? "Yes" : "No");
	printf("  Support host page-locked memory mapping:       %s\n",
			deviceProp.canMapHostMemory ? "Yes" : "No");
	printf("  Alignment requirement for Surfaces:            %s\n",
			deviceProp.surfaceAlignment ? "Yes" : "No");
	printf("  Device has ECC support:                        %s\n",
			deviceProp.ECCEnabled ? "Enabled" : "Disabled");
#if defined(WIN32) || defined(_WIN32) || defined(WIN64) || defined(_WIN64)
	printf("  CUDA Device Driver Mode (TCC or WDDM):         %s\n",
			deviceProp.tccDriver ? "TCC (Tesla Compute Cluster Driver)"
			: "WDDM (Windows Display Driver Model)");
#endif
	printf("  Device supports Unified Addressing (UVA):      %s\n",
			deviceProp.unifiedAddressing ? "Yes" : "No");
	printf("  Device supports Compute Preemption:            %s\n",
			deviceProp.computePreemptionSupported ? "Yes" : "No");
	printf("  Supports Cooperative Kernel Launch:            %s\n",
			deviceProp.cooperativeLaunch ? "Yes" : "No");
	printf("  Supports MultiDevice Co-op Kernel Launch:      %s\n",
			deviceProp.cooperativeMultiDeviceLaunch ? "Yes" : "No");
	printf("  Device PCI Domain ID / Bus ID / location ID:   %d / %d / %d\n",
			deviceProp.pciDomainID, deviceProp.pciBusID,
			deviceProp.pciDeviceID);

}

int main(void) {
	get_device_information(0);
	test_l1_cache_kepler(10);
	return 0;
}

