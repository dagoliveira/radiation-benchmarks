//============================================================================
//	UPDATE
//============================================================================

//	14 APR 2011 Lukasz G. Szafaryn
//  2014-2018 Caio Lunardi
//  2018 Fernando Fernandes dos Santos

#include <iostream>
#include <sys/time.h>
#include <cuda_fp16.h>
#include <fstream>

#ifdef USE_OMP
#include <omp.h>
#endif

#ifdef LOGS

#include "log_helper.h"

#ifdef BUILDPROFILER

#ifdef FORJETSON
#include "include/JTX2Inst.h"
#define OBJTYPE JTX2Inst
#else
#include "include/NVMLWrapper.h"
#define OBJTYPE NVMLWrapper
#endif // FORJETSON

#endif // BUILDPROFILER

#endif // LOGHELPER

#include "cuda_utils.h"
#include "Parameters.h"
#include "Log.h"
#include "types.h"
#include "common.h"
#include "nondmr_kernels.h"

template<typename tested_type>
void generateInput(dim_str dim_cpu, const std::string& input_distances,
		std::vector<FOUR_VECTOR<tested_type>>& rv_cpu,
		const std::string& input_charges, std::vector<tested_type>& qv_cpu) {
	// random generator seed set to random value - time in this case
	std::cout << ("Generating input...\n");

	srand(time(NULL));

	std::ofstream input_distances_file(input_distances, std::ofstream::binary);

	if (input_distances_file.good()) {
		rv_cpu.resize(dim_cpu.space_elem);

		for (auto& rv_cpu_i : rv_cpu) {
			// get a number in the range 0.1 - 1.0
			rv_cpu_i.v = tested_type((rand() % 10 + 1) / tested_type(10.0));
			rv_cpu_i.x = tested_type((rand() % 10 + 1) / tested_type(10.0));
			rv_cpu_i.y = tested_type((rand() % 10 + 1) / tested_type(10.0));
			rv_cpu_i.z = tested_type((rand() % 10 + 1) / tested_type(10.0));

			//operator already overloaded
			input_distances_file << rv_cpu_i;
		}
		input_distances_file.close();

	} else {
		error("The file 'input_distances' was not opened\n");
	}

	std::ofstream input_charges_file(input_charges, std::ofstream::binary);
	if (input_charges_file.good()) {

		qv_cpu.resize(dim_cpu.space_elem);
		for (auto& qv_cpu_i : qv_cpu) {
			// get a number in the range 0.1 - 1.0
			qv_cpu_i = tested_type((rand() % 10 + 1) / tested_type(10.0));

			input_charges_file << qv_cpu_i;
		}
		input_charges_file.close();
	} else {
		error("The file 'input_charges' was not opened\n");
	}
}

template<typename tested_type>
void readInput(dim_str dim_cpu, const std::string& input_distances,
		std::vector<FOUR_VECTOR<tested_type>>& rv_cpu,
		const std::string& input_charges, std::vector<tested_type>& qv_cpu,
		int fault_injection) {

	std::ifstream input_distances_file(input_distances, std::ifstream::binary);

	if (input_distances_file.good()) {
		rv_cpu.resize(dim_cpu.space_elem);

		for (auto& rv_cpu_i : rv_cpu) {
			bool return_value = !(input_distances_file >> rv_cpu_i);
			if (return_value) {
				error("error reading rv_cpu from file");
			}

		}
		input_distances_file.close();
	} else {
		error("The file 'input_distances' was not opened\n");
	}

	std::ifstream input_charges_file(input_charges, std::ifstream::binary);

	if (input_charges_file.good()) {
		qv_cpu.resize(dim_cpu.space_elem);

		for (auto& qv_cpu_i : qv_cpu) {
			bool return_value = !(input_charges_file >> qv_cpu_i);
			if (return_value) {
				error("error reading qv_cpu from file\n");
			}
		}
		input_charges_file.close();
	} else {
		error("The file 'input_charges' was not opened\n");
	}
	// =============== Fault injection
	if (fault_injection) {
		qv_cpu[2] = 0.732637263; // must be in range 0.1 - 1.0
		std::cout << "!!> Fault injection: qv_cpu[2]= " << qv_cpu[2]
				<< std::endl;
	}
	// ========================
}

template<typename tested_type>
void readGold(dim_str dim_cpu, const std::string& output_gold,
		std::vector<FOUR_VECTOR<tested_type>>& fv_cpu_GOLD) {

	std::ifstream gold_file(output_gold, std::ifstream::binary);

	if (gold_file.good()) {
		for (auto& gold_i : fv_cpu_GOLD) {
			bool return_value = !(gold_file >> gold_i);
			if (return_value) {
				error("error reading rv_cpu from file\n");
			}
		}

		gold_file.close();
	} else {
		error("The file 'output_forces' was not opened\n");
	}
}

template<typename tested_type>
void writeGold(dim_str dim_cpu, const std::string& output_gold,
		std::vector<FOUR_VECTOR<tested_type>>& fv_cpu) {

	std::ofstream gold_file(output_gold, std::ifstream::binary);
	int number_zeros = 0;

	if (gold_file.good()) {
		for (auto& fv_cpu_i : fv_cpu) {

			if (fv_cpu_i.v == tested_type(0.0))
				number_zeros++;
			if (fv_cpu_i.x == tested_type(0.0))
				number_zeros++;
			if (fv_cpu_i.y == tested_type(0.0))
				number_zeros++;
			if (fv_cpu_i.z == tested_type(0.0))
				number_zeros++;

			bool return_value = !(gold_file << fv_cpu_i);
			if (return_value) {
				error("error writing rv_cpu from file\n");
			}
		}

		gold_file.close();
	} else {
		error("The file 'output_forces' was not opened\n");
	}

	std::cout << "Number of zeros " << number_zeros << std::endl;
}

template<typename tested_type>
void gpu_memory_setup(const Parameters& parameters, dim_str dim_cpu,
		VectorOfDeviceVector<box_str>& d_box_gpu, std::vector<box_str>& box_cpu,
		VectorOfDeviceVector<FOUR_VECTOR<tested_type>>& d_rv_gpu,
		std::vector<FOUR_VECTOR<tested_type>>& rv_cpu,
		VectorOfDeviceVector<tested_type>& d_qv_gpu,
		std::vector<tested_type>& qv_cpu,
		VectorOfDeviceVector<FOUR_VECTOR<tested_type>>& d_fv_gpu,
		rad::DeviceVector<FOUR_VECTOR<tested_type>>& d_fv_gold_gpu,
		std::vector<FOUR_VECTOR<tested_type>>& fv_cpu_GOLD) {

	for (int streamIdx = 0; streamIdx < parameters.nstreams; streamIdx++) {
		d_box_gpu[streamIdx] = box_cpu;
		d_rv_gpu[streamIdx] = rv_cpu;
		d_qv_gpu[streamIdx] = qv_cpu;
	}

	if (parameters.gpu_check) {
		d_fv_gold_gpu = fv_cpu_GOLD;
	}
}

template<typename tested_type>
void gpu_memory_unset(int nstreams, int gpu_check,
		VectorOfDeviceVector<box_str>& d_box_gpu,
		VectorOfDeviceVector<FOUR_VECTOR<tested_type>>& d_rv_gpu,
		VectorOfDeviceVector<tested_type>& d_qv_gpu,
		VectorOfDeviceVector<FOUR_VECTOR<tested_type>>& d_fv_gpu,
		rad::DeviceVector<FOUR_VECTOR<tested_type>>& d_fv_gold_gpu) {

	//=====================================================================
	//	GPU MEMORY DEALLOCATION
	//=====================================================================
	for (int streamIdx = 0; streamIdx < nstreams; streamIdx++) {
		d_rv_gpu[streamIdx].resize(0);
		d_qv_gpu[streamIdx].resize(0);
		d_fv_gpu[streamIdx].resize(0);
		d_box_gpu[streamIdx].resize(0);
	}
	if (gpu_check) {
		d_fv_gold_gpu.resize(0);
	}
}

// Returns true if no errors are found. False if otherwise.
// Set votedOutput pointer to retrieve the voted matrix
template<typename tested_type>
bool checkOutputErrors(int verbose, dim_str dim_cpu, int streamIdx,
		std::vector<FOUR_VECTOR<tested_type>>& fv_cpu,
		std::vector<FOUR_VECTOR<tested_type>>& fv_cpu_GOLD) {
	int host_errors = 0;

//#pragma omp parallel for shared(host_errors)
//	for (int i = 0; i < dim_cpu.space_elem; i = i + 1) {
//		FOUR_VECTOR<tested_type> valGold = fv_cpu_GOLD[i];
//		FOUR_VECTOR<tested_type> valOutput = fv_cpu[i];
//		if (valGold != valOutput) {
//#pragma omp critical
//			{
//				char error_detail[500];
//				host_errors++;
//
//				snprintf(error_detail, 500,
//						"stream: %d, p: [%d], v_r: %1.20e, v_e: %1.20e, x_r: %1.20e, x_e: %1.20e, y_r: %1.20e, y_e: %1.20e, z_r: %1.20e, z_e: %1.20e\n",
//						streamIdx, i, (double) valOutput.v, (double) valGold.v,
//						(double) valOutput.x, (double) valGold.x,
//						(double) valOutput.y, (double) valGold.y,
//						(double) valOutput.z, (double) valGold.z);
//				if (verbose && (host_errors < 10))
//					printf("%s\n", error_detail);
//#ifdef LOGS
//				if ((host_errors<MAX_LOGGED_ERRORS_PER_STREAM))
//				log_error_detail(error_detail);
//#endif
//			}
//		}
//	}
//
//	// printf("numErrors:%d", host_errors);
//
//#ifdef LOGS
//	log_error_count(host_errors);
//#endif
//	if (host_errors != 0)
//		printf("#");

	return (host_errors == 0);
}

template<typename tested_type>
void setup_execution(const Parameters& parameters, Log& log) {
	//=====================================================================
	//	CPU/MCPU VARIABLES
	//=====================================================================
	// timer
	double timestamp;
	// counters
//	int i, j, k, l, m, n;
//	int iterations;

	// system memory
	par_str<tested_type> par_cpu;
	dim_str dim_cpu;
	std::vector<box_str> box_cpu;
	std::vector<FOUR_VECTOR<tested_type>> rv_cpu;
	std::vector<tested_type> qv_cpu;
	std::vector<FOUR_VECTOR<tested_type>> fv_cpu_GOLD;
	int nh;
//	int nstreams, streamIdx;

	int number_nn = 0;
	//=====================================================================
	//	CHECK INPUT ARGUMENTS
	//=====================================================================

	dim_cpu.boxes1d_arg = parameters.boxes;

	//=====================================================================
	//	INPUTS
	//=====================================================================
	par_cpu.alpha = 0.5;
	//=====================================================================
	//	DIMENSIONS
	//=====================================================================
	// total number of boxes
	dim_cpu.number_boxes = dim_cpu.boxes1d_arg * dim_cpu.boxes1d_arg
			* dim_cpu.boxes1d_arg;
	// how many particles space has in each direction
	dim_cpu.space_elem = dim_cpu.number_boxes * NUMBER_PAR_PER_BOX;
	dim_cpu.space_mem = dim_cpu.space_elem * sizeof(FOUR_VECTOR<tested_type> );
	dim_cpu.space_mem2 = dim_cpu.space_elem * sizeof(tested_type);
	// box array
	dim_cpu.box_mem = dim_cpu.number_boxes * sizeof(box_str);
	//=====================================================================
	//	SYSTEM MEMORY
	//=====================================================================
	// prepare host memory to receive kernel output
	// output (forces)
	std::vector<FOUR_VECTOR<tested_type>> fv_cpu[parameters.nstreams];

	for (int streamIdx = 0; streamIdx < parameters.nstreams; streamIdx++) {
		fv_cpu[streamIdx].resize(dim_cpu.space_elem);
	}

	fv_cpu_GOLD.resize(dim_cpu.space_elem);
	//=====================================================================
	//	BOX
	//=====================================================================
	// allocate boxes
	box_cpu.resize(dim_cpu.number_boxes);

	// initialize number of home boxes
	nh = 0;
	// home boxes in z direction
	for (int i = 0; i < dim_cpu.boxes1d_arg; i++) {
		// home boxes in y direction
		for (int j = 0; j < dim_cpu.boxes1d_arg; j++) {
			// home boxes in x direction
			for (int k = 0; k < dim_cpu.boxes1d_arg; k++) {
				// current home box
				box_cpu[nh].x = k;
				box_cpu[nh].y = j;
				box_cpu[nh].z = i;
				box_cpu[nh].number = nh;
				box_cpu[nh].offset = nh * NUMBER_PAR_PER_BOX;
				// initialize number of neighbor boxes
				box_cpu[nh].nn = 0;
				// neighbor boxes in z direction
				for (int l = -1; l < 2; l++) {
					// neighbor boxes in y direction
					for (int m = -1; m < 2; m++) {
						// neighbor boxes in x direction
						for (int n = -1; n < 2; n++) {
							// check if (this neighbor exists) and (it is not the same as home box)
							if ((((i + l) >= 0 && (j + m) >= 0 && (k + n) >= 0)
									== true
									&& ((i + l) < dim_cpu.boxes1d_arg
											&& (j + m) < dim_cpu.boxes1d_arg
											&& (k + n) < dim_cpu.boxes1d_arg)
											== true)
									&& (l == 0 && m == 0 && n == 0) == false) {
								// current neighbor box
								box_cpu[nh].nei[box_cpu[nh].nn].x = (k + n);
								box_cpu[nh].nei[box_cpu[nh].nn].y = (j + m);
								box_cpu[nh].nei[box_cpu[nh].nn].z = (i + l);
								box_cpu[nh].nei[box_cpu[nh].nn].number =
										(box_cpu[nh].nei[box_cpu[nh].nn].z
												* dim_cpu.boxes1d_arg
												* dim_cpu.boxes1d_arg)
												+ (box_cpu[nh].nei[box_cpu[nh].nn].y
														* dim_cpu.boxes1d_arg)
												+ box_cpu[nh].nei[box_cpu[nh].nn].x;
								box_cpu[nh].nei[box_cpu[nh].nn].offset =
										box_cpu[nh].nei[box_cpu[nh].nn].number
												* NUMBER_PAR_PER_BOX;
								// increment neighbor box
								box_cpu[nh].nn = box_cpu[nh].nn + 1;
								number_nn += box_cpu[nh].nn;
							}
						} // neighbor boxes in x direction
					} // neighbor boxes in y direction
				} // neighbor boxes in z direction
				  // increment home box
				nh = nh + 1;
			} // home boxes in x direction
		} // home boxes in y direction
	} // home boxes in z direction
	  //=====================================================================
	  //	PARAMETERS, DISTANCE, CHARGE AND FORCE
	  //=====================================================================
	if (parameters.generate) {
		generateInput(dim_cpu, parameters.input_distances, rv_cpu,
				parameters.input_charges, qv_cpu);
	} else {
		readInput(dim_cpu, parameters.input_distances, rv_cpu,
				parameters.input_charges, qv_cpu, parameters.fault_injection);
		readGold(dim_cpu, parameters.output_gold, fv_cpu_GOLD);
	}
	//=====================================================================
	//	EXECUTION PARAMETERS
	//=====================================================================
	dim3 threads;
	dim3 blocks;
	blocks.x = dim_cpu.number_boxes;
	blocks.y = 1;
	// define the number of threads in the block
	threads.x = NUMBER_THREADS;
	threads.y = 1;
	//=====================================================================
	//	GPU_CUDA
	//=====================================================================
	//=====================================================================
	//	STREAMS
	//=====================================================================
	std::vector<CudaStream> streams(parameters.nstreams);

	//=====================================================================
	//	VECTORS
	//=====================================================================
	VectorOfDeviceVector<box_str> d_box_gpu(parameters.nstreams);
	VectorOfDeviceVector<FOUR_VECTOR<tested_type>> d_rv_gpu(
			parameters.nstreams);
	VectorOfDeviceVector<tested_type> d_qv_gpu(parameters.nstreams);
	VectorOfDeviceVector<FOUR_VECTOR<tested_type>> d_fv_gpu(
			parameters.nstreams);
	rad::DeviceVector<FOUR_VECTOR<tested_type>> d_fv_gold_gpu;
	//=====================================================================
	//	GPU MEMORY SETUP
	//=====================================================================
	for (int streamIdx = 0; streamIdx < parameters.nstreams; streamIdx++) {
		d_box_gpu[streamIdx] = box_cpu;
		d_rv_gpu[streamIdx] = rv_cpu;
		d_qv_gpu[streamIdx] = qv_cpu;
	}

	if (parameters.gpu_check) {
		d_fv_gold_gpu = fv_cpu_GOLD;
	}

//	gpu_memory_setup(parameters, dim_cpu, d_box_gpu, box_cpu, d_rv_gpu, rv_cpu,
//			d_qv_gpu, qv_cpu, d_fv_gpu, d_fv_gold_gpu, fv_cpu_GOLD);

	//LOOP START
	for (int loop = 0; loop < parameters.iterations; loop++) {

		if (parameters.verbose)
			printf("======== Iteration #%06u ========\n", loop);

		double globaltimer = rad::mysecond();
		timestamp = rad::mysecond();

		// for(i=0; i<dim_cpu.space_elem; i=i+1) {
		// 	// set to 0, because kernels keeps adding to initial value
		// 	fv_cpu[i].v = tested_type(0.0);
		// 	fv_cpu[i].x = tested_type(0.0);
		// 	fv_cpu[i].y = tested_type(0.0);
		// 	fv_cpu[i].z = tested_type(0.0);
		// }

		//=====================================================================
		//	GPU SETUP
		//=====================================================================
		for (int streamIdx = 0; streamIdx < parameters.nstreams; streamIdx++) {
			std::fill(fv_cpu[streamIdx].begin(), fv_cpu[streamIdx].end(),
					FOUR_VECTOR<tested_type>());
			d_fv_gpu[streamIdx].clear();
		}

		if (parameters.verbose)
			printf("Setup prepare time: %.4fs\n", rad::mysecond() - timestamp);

		//=====================================================================
		//	KERNEL
		//=====================================================================

		double kernel_time = rad::mysecond();
		log.start_iteration();

		// launch kernel - all boxes
		for (int streamIdx = 0; streamIdx < parameters.nstreams; streamIdx++) {
			kernel_gpu_cuda<<<blocks, threads, 0, streams[streamIdx].stream>>>(
					par_cpu, dim_cpu, d_box_gpu[streamIdx].data(),
					d_rv_gpu[streamIdx].data(), d_qv_gpu[streamIdx].data(),
					d_fv_gpu[streamIdx].data());
			rad::checkFrameworkErrors(cudaPeekAtLastError());
		}

		for (auto& st : streams) {
			st.sync();
			rad::checkFrameworkErrors(cudaPeekAtLastError());
		}

		log.end_iteration();
		kernel_time = rad::mysecond() - kernel_time;

		//=====================================================================
		//	COMPARE OUTPUTS / WRITE GOLD
		//=====================================================================
		if (parameters.generate) {
			fv_cpu_GOLD = d_fv_gpu[0].to_vector();
			writeGold(dim_cpu, parameters.output_gold, fv_cpu_GOLD);
		} else {
			timestamp = rad::mysecond();
			{
				bool reloadFlag = false;
#pragma omp parallel for shared(reloadFlag)
				for (int streamIdx = 0; streamIdx < parameters.nstreams;
						streamIdx++) {
					fv_cpu[streamIdx] = d_fv_gpu[streamIdx].to_vector();
					reloadFlag = reloadFlag
							|| checkOutputErrors(parameters.verbose, dim_cpu,
									streamIdx, fv_cpu[streamIdx], fv_cpu_GOLD);
				}
				if (reloadFlag) {
					readInput(dim_cpu, parameters.input_distances, rv_cpu,
							parameters.input_charges, qv_cpu,
							parameters.fault_injection);
					readGold(dim_cpu, parameters.output_gold, fv_cpu_GOLD);

					gpu_memory_unset(parameters.nstreams, parameters.gpu_check,
							d_box_gpu, d_rv_gpu, d_qv_gpu, d_fv_gpu,
							d_fv_gold_gpu);
					gpu_memory_setup(parameters, dim_cpu, d_box_gpu, box_cpu,
							d_rv_gpu, rv_cpu, d_qv_gpu, qv_cpu, d_fv_gpu,
							d_fv_gold_gpu, fv_cpu_GOLD);
				}
			}
			if (parameters.verbose)
				printf("Gold check time: %f\n", rad::mysecond() - timestamp);
		}

		//================= PERF
		// iterate for each neighbor of a box (number_nn)
		double flop = number_nn;
		// The last for iterate NUMBER_PAR_PER_BOX times
		flop *= NUMBER_PAR_PER_BOX;
		// the last for uses 46 operations plus 2 exp() functions
		flop *= 46;
		flop *= parameters.nstreams;
		double flops = flop / kernel_time;
		double outputpersec = dim_cpu.space_elem * 4 * parameters.nstreams
				/ kernel_time;
		double iteration_time = rad::mysecond() - globaltimer;

		if (parameters.verbose) {
			std::cout << "BOXES: " << dim_cpu.boxes1d_arg;
			std::cout << " BLOCK:%d " << NUMBER_THREADS;
			std::cout << " OUTPUT/S:" << outputpersec;
			std::cout << " FLOPS:" << flops;
			std::cout << "(GFLOPS:" << flops / 1.0e9 << ") ";
			std::cout << "Kernel time:" << kernel_time << std::endl;

			std::cout << "Iteration time: " << iteration_time << "s ("
					<< (kernel_time / iteration_time) * 100.0 << "% of Device)"
					<< std::endl;

			std::cout << "===================================" << std::endl;
		} else {
			std::cout << ".";
		}

	}
	gpu_memory_unset(parameters.nstreams, parameters.gpu_check, d_box_gpu,
			d_rv_gpu, d_qv_gpu, d_fv_gpu, d_fv_gold_gpu);

}

//=============================================================================
//	MAIN FUNCTION
//=============================================================================

int main(int argc, char *argv[]) {

	//=====================================================================
	//	CPU/MCPU VARIABLES
	//=====================================================================
	Parameters parameters(argc, argv);
	Log log;
	std::cout << parameters << std::endl;
//	char test_info[200];
//	char test_name[200];
//	snprintf(test_info, 200,
//			"type:%s-precision streams:%d boxes:%d block_size:%d",
//			test_precision_description, parameters.nstreams, dim_cpu.boxes1d_arg,
//			NUMBER_THREADS);
//	snprintf(test_name, 200, "cuda_%s_lava", test_precision_description);
//	printf(
//			"\n=================================\n%s\n%s\n=================================\n\n",
//			test_name, test_info);

	// timer
#ifdef LOGS
	if (!generate) {
		start_log_file(test_name, test_info);
		set_max_errors_iter(MAX_LOGGED_ERRORS_PER_STREAM * nstreams + 32);
	}

#ifdef BUILDPROFILER

	std::string log_file_name(get_log_file_name());
	if(generate) {
		log_file_name = "/tmp/generate.log";
	}
//	rad::Profiler profiler_thread = new rad::JTX2Inst(log_file_name);
	std::shared_ptr<rad::Profiler> profiler_thread = std::make_shared<rad::OBJTYPE>(0, log_file_name);

//START PROFILER THREAD
	profiler_thread->start_profile();
#endif
#endif

	setup_execution<float>(parameters, log);

#ifdef LOGS
#ifdef BUILDPROFILER
	profiler_thread->end_profile();
#endif
	if (!generate) end_log_file();
#endif

	return 0;
}
