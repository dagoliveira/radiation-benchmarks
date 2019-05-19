/*
 * HotspotExecute.cpp
 *
 *  Created on: 18/05/2019
 *      Author: fernando
 */

#include "HotspotExecute.h"
#include "none_kernels.h"

#ifdef LOGS
#include "log_helper.h"
#endif
// The timestamp is updated on every log_helper function call.

HotspotExecute::HotspotExecute(int argc, char** argv) {
	std::cout << "WG size of kernel = " << BLOCK_SIZE << " " << BLOCK_SIZE
			<< std::endl;

	this->setupParams = Parameters(argc, argv);

	std::string test_info = std::string("streams:")
			+ std::to_string(this->setupParams.nstreams) + " precision:"
			+ this->setupParams.test_precision_description + " size:"
			+ std::to_string(this->setupParams.grid_rows) + +" pyramidHeight:"
			+ std::to_string(this->setupParams.pyramid_height) + " simTime:"
			+ std::to_string(this->setupParams.sim_time);
	std::string test_name = "cuda_hotspot_"
			+ this->setupParams.test_precision_description;

	this->log = Log(test_name, test_info, this->setupParams.generate);

	std::cout << std::endl << test_name << std::endl << test_info << std::endl;

}

template<typename full>
int HotspotExecute::compute_tran_temp(DataManagement<full>& hotspot_data,
		int col, int row, int sim_time, int num_iterations, int blockCols,
		int blockRows, int borderCols, int borderRows, cudaStream_t stream) {

//	dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
//	dim3 dimGrid(blockCols, blockRows);
//
//	tested_type_host t_chip(0.0005);
//	tested_type_host chip_height(0.016);
//	tested_type_host chip_width(0.016);
//
//	float grid_height = chip_height / row;
//	float grid_width = chip_width / col;
//
//	float Cap = FACTOR_CHIP * SPEC_HEAT_SI * t_chip * grid_width * grid_height;
//	float Rx = grid_width / (2.0 * K_SI * t_chip * grid_height);
//	float Ry = grid_height / (2.0 * K_SI * t_chip * grid_width);
//	float Rz = t_chip / (K_SI * grid_height * grid_width);
//
//	float max_slope = MAX_PD / (FACTOR_CHIP * t_chip * SPEC_HEAT_SI);
//	float step = PRECISION / max_slope;
//	float t;
//	float time_elapsed;
//	time_elapsed = 0.001;
//
//	int src = 1, dst = 0;
//	for (t = 0; t < sim_time; t += num_iterations) {
//		int temp = src;
//		src = dst;
//		dst = temp;
//		//printf("[%d]", omp_get_thread_num());
//		calculate_temp<<<dimGrid, dimBlock, 0, stream>>>(
//				MIN(num_iterations, sim_time - t), (tested_type*) MatrixPower,
//				(tested_type*) MatrixTemp[src], (tested_type*) MatrixTemp[dst],
//				col, row, borderCols, borderRows, Cap, Rx, Ry, Rz, step,
//				time_elapsed);
//		flops += col * row * MIN(num_iterations, sim_time - t) * 15;
//	}
//	cudaStreamSynchronize(stream);
//	return dst;
	return 0;
}

template<typename full>
void HotspotExecute::generic_execute(int size, double globaltime,
		double timestamp, int blockCols, int blockRows, int borderCols,
		int borderRows) {
	DataManagement<full> hotspot_data(this->setupParams.nstreams, size);

	//TODO: FIX IT
	hotspot_data.readInput();

	// ====================== MAIN BENCHMARK CYCLE ======================
	for (int loop1 = 0; loop1 < (this->setupParams.setup_loops); loop1++) {
		if (this->setupParams.verbose)
			printf("======== Iteration #%06u ========\n", loop1);

		globaltime = this->log.mysecond();
		// ============ PREPARE ============
		std::vector<int> ret(this->setupParams.nstreams);
		timestamp = this->log.mysecond();
		hotspot_data.reload();
		if (this->setupParams.verbose)
			printf("GPU prepare time: %.4fs\n",
					this->log.mysecond() - timestamp);

		// ============ COMPUTE ============
		double kernel_time = this->log.mysecond();
		this->log.start_iteration_app();
		for (int streamIdx = 0; streamIdx < (this->setupParams.nstreams);
				streamIdx++) {
			ret[streamIdx] = compute_tran_temp(hotspot_data,
					this->setupParams.grid_cols, this->setupParams.grid_rows,
					this->setupParams.sim_time,
					this->setupParams.pyramid_height, blockCols, blockRows,
					borderCols, borderRows, hotspot_data.streams[streamIdx]);
		}

		for (auto stream : hotspot_data.streams) {
			cudaStreamSynchronize(stream);
		}
		this->log.end_iteration_app();
		kernel_time = this->log.mysecond() - kernel_time;
		// ============ MEASURE PERFORMANCE ============
		if (this->setupParams.verbose) {
			double outputpersec = (double) (((this->setupParams.grid_rows
					* this->setupParams.grid_rows * this->setupParams.nstreams)
					/ kernel_time));
			printf("Kernel time: %.4lfs\n", kernel_time);
//			printf(
//					"Performance - SIZE:%d OUTPUT/S:%f FLOPS: %f (GFLOPS: %.2f)\n",
//					this->setupParams.grid_rows, outputpersec,
//					(double) (flops) / kernel_time,
//					(double) (flops) / (kernel_time * 1000000000));
		}
//		flops = 0;
		// ============ VALIDATE OUTPUT ============
		timestamp = this->log.mysecond();
		int kernel_errors = 0;

		hotspot_data.copy_from_gpu();

		if (this->setupParams.generate) {
			hotspot_data.writeOutput();
		} else {
				hotspot_data.check_output_errors();
		}

		if (this->setupParams.verbose)
			printf("Gold check time: %.4fs\n", this->log.mysecond() - timestamp);

		if ((kernel_errors != 0) && !(this->setupParams.verbose))
			printf(".");

		double iteration_time = this->log.mysecond() - globaltime;
		if (this->setupParams.verbose)
			printf("Iteration time: %.4fs (%3.1f%% Device)\n", iteration_time,
					(kernel_time / iteration_time) * 100.0);

		if (this->setupParams.verbose)
			printf("===================================\n");

		fflush(stdout);
	}
}

HotspotExecute::~HotspotExecute() {
}

void HotspotExecute::run() {
	//int streamIdx;
	double timestamp, globaltime;

//		parameters *setupParams = (parameters *) malloc(sizeof(parameters));

// =============== Get setup parameters from command line
//		getParams(argc, argv, setupParams);
	// =======================

	// ===============  pyramid parameters
# define EXPAND_RATE 2// add one iteration will extend the pyramid base by 2 per each borderline
	int borderCols = (this->setupParams.pyramid_height) * EXPAND_RATE / 2;
	int borderRows = (this->setupParams.pyramid_height) * EXPAND_RATE / 2;
	int smallBlockCol = BLOCK_SIZE
			- (this->setupParams.pyramid_height) * EXPAND_RATE;
	int smallBlockRow = BLOCK_SIZE
			- (this->setupParams.pyramid_height) * EXPAND_RATE;
	int blockCols = this->setupParams.grid_cols / smallBlockCol
			+ ((this->setupParams.grid_cols % smallBlockCol == 0) ? 0 : 1);
	int blockRows = this->setupParams.grid_rows / smallBlockRow
			+ ((this->setupParams.grid_rows % smallBlockRow == 0) ? 0 : 1);

	int size = (this->setupParams.grid_cols) * (this->setupParams.grid_rows);

	generic_execute<float>(size, globaltime, timestamp, blockCols, blockRows,
			borderCols, borderRows);
}