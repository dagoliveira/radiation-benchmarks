/*
 ============================================================================
 Name        : main.cpp
 Author      : Fernando
 Version     :
 Copyright   : Your copyright notice
 Description : CUDA compute reciprocals
 ============================================================================
 */

#include <iostream>
#include <iomanip>      // std::setprecision

#include "utils.h"
#include "Parameters.h"

#include "MicroLDST.h"
#include "MicroInt.h"
#include "MicroReal.h"

#include "cuda_utils.h"
#include "generic_log.h"

template<typename real_t>
void setup_execute(Parameters& test_parameter, Micro<real_t>& micro_obj) {

	if (!test_parameter.generate) {
		micro_obj.get_setup_input();
	}

	for (size_t iteration = 0; iteration < test_parameter.iterations;
			iteration++) {

		auto start_it = rad::mysecond();
		//Start iteration
		micro_obj.log->start_iteration();
		micro_obj.execute_micro();

		rad::checkFrameworkErrors(cudaGetLastError());
		rad::checkFrameworkErrors(cudaDeviceSynchronize());

		//end iteration
		micro_obj.log->end_iteration();
		auto end_it = rad::mysecond();

		//Copying from GPU
		auto start_cpy = rad::mysecond();
		micro_obj.copy_back_output();
		auto end_cpy = rad::mysecond();

		//Comparing the output
		auto start_cmp = rad::mysecond();
		size_t errors = 0;
		if (test_parameter.generate == false) {
			errors = micro_obj.compare_output();
			//update errors
			micro_obj.log->update_errors();
			micro_obj.log->update_infos();
		}
		auto end_cmp = rad::mysecond();

		auto start_reset_output = rad::mysecond();
		if (test_parameter.generate == false)
			micro_obj.reset_output_device();
		auto end_reset_output = rad::mysecond();

		if (test_parameter.verbose) {
			// PERF
			auto kernel_time = end_it - start_it;
			auto cmp_time = end_cmp - start_cmp;
			auto copy_time = end_cpy - start_cpy;
			auto reset_time = end_reset_output - start_reset_output;
			auto wasted_time = cmp_time + copy_time + reset_time;

			std::cout << "Iteration " << iteration;
			std::cout << " Kernel time: " << kernel_time;
			std::cout << " Output errors: " << errors;
			std::cout << " Memory errors: " << errors;
			std::cout << " Wasted time (copy + compare + reset): "
					<< wasted_time;
			std::cout << " Wasted time percentage: "
					<< (wasted_time / kernel_time) * 100.0 << "%";
			std::cout << " Comparison time: " << cmp_time;
			std::cout << " Copy time: " << copy_time;
			std::cout << " Reset time: " << reset_time << std::endl;
		}
	}

	if (test_parameter.generate) {
		auto success = micro_obj.save_output();
		if (success == false) {
			throw_line(
					"Could not generate the gold file due memory errors, run it again\n");
		}
	}
}

int main(int argc, char **argv) {
	std::cout << std::setprecision(6) << std::setfill('0');

	//================== Set block and grid size for MxM kernel
	Parameters parameters(argc, argv);
	std::shared_ptr<rad::Log> log_ptr;

	//================== Init logs
	std::string test_info = "";
	test_info += " gridsize:" + std::to_string(parameters.grid_size);
	test_info += " blocksize:" + std::to_string(parameters.block_size);
	test_info += " type:" + parameters.instruction_str + "-"
			+ parameters.precision_str;
	test_info += " opnum:" + std::to_string(parameters.operation_num);
	test_info += " fast_math:" + std::to_string(parameters.fast_math);
	test_info += " memory_used:"
			+ std::to_string(parameters.memory_size_to_use);
	auto internal_iterations =
			(parameters.micro == LDST) ?
					std::to_string(MAX_THREAD_LD_ST_OPERATIONS) :
					std::to_string(LOOPING_UNROLL);
	test_info += " internal_iterations:" + internal_iterations;

	std::string test_name = std::string("cuda_micro-")
			+ parameters.instruction_str + "-" + parameters.precision_str;

	log_ptr = std::make_shared<rad::Log>(test_name, test_info, 10);

	if (parameters.verbose) {
		std::cout << *log_ptr << std::endl;
		std::cout << parameters << std::endl;
	}

	switch (parameters.precision) {
	case INT32: {
		switch (parameters.micro) {
		case LDST: {
			MicroLDST<int32_t> micro_obj(parameters, log_ptr);
			setup_execute(parameters, micro_obj);
			break;
		}
		case BRANCH: {
			MicroBranch<int32_t> micro_obj(parameters, log_ptr);
			setup_execute(parameters, micro_obj);
			break;
		}
		case ADD:
		case MUL:
		case FMA:
		case MAD: {
			MicroInt<int32_t> micro_obj(parameters, log_ptr);
			setup_execute(parameters, micro_obj);
		}
		}
		return 0;
	}
	case SINGLE: {
		switch (parameters.micro) {
		case ADD:
		case MUL:
		case FMA:
		case MAD:
		case EULER:
		case PYTHAGOREAN:
		case DIV:
			MicroReal<float> micro_obj(parameters, log_ptr);
			setup_execute(parameters, micro_obj);
		}
		return 0;
	}
	case HALF:
	case DOUBLE:
		throw_line("not implemented yet")
		;
	}
}

