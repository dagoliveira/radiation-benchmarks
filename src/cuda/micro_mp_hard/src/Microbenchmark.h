/*
 * Microbenchmark.h
 *
 *  Created on: 15/09/2019
 *      Author: fernando
 */

#ifndef MICROBENCHMARK_H_
#define MICROBENCHMARK_H_

#include <tuple>
#include <sstream>
#include <omp.h>

#include "device_vector.h"
#include "Parameters.h"
#include "Log.h"
#include "none_kernels.h"

template<const uint32 CHECK_BLOCK, typename half_t, typename real_t>
struct Microbenchmark {

	rad::DeviceVector<real_t> output_dev_1, output_dev_2, output_dev_3;
	std::vector<real_t> output_host_1, output_host_2, output_host_3;
	std::vector<real_t> gold_vector;

	Log& log_;

	const Parameters& parameters_;

	virtual ~Microbenchmark() = default;

	Microbenchmark(const Parameters& parameters, Log& log) :
			parameters_(parameters), log_(log) {
		this->output_dev_1.resize(this->parameters_.r_size);
		this->output_dev_2.resize(this->parameters_.r_size);
		this->output_dev_3.resize(this->parameters_.r_size);
		this->gold_vector.resize(this->parameters_.r_size);
	}

	virtual void call_kernel() {
		//================== Device computation
		switch (parameters_.micro) {
		case ADD:
			microbenchmark_kernel_add<<<parameters_.grid_size,
					parameters_.block_size>>>(output_dev_1.data(),
					output_dev_2.data(), output_dev_3.data());
			break;
		case MUL:
			microbenchmark_kernel_mul<<<parameters_.grid_size,
					parameters_.block_size>>>(output_dev_1.data(),
					output_dev_2.data(), output_dev_3.data());
			break;
		case FMA:
			microbenchmark_kernel_fma<<<parameters_.grid_size,
					parameters_.block_size>>>(output_dev_1.data(),
					output_dev_2.data(), output_dev_3.data());
			break;
		}
	}

	void test() {
		this->log_.start_iteration();
		this->call_kernel();

		rad::checkFrameworkErrors(cudaDeviceSynchronize());
		rad::checkFrameworkErrors(cudaPeekAtLastError());
		this->log_.end_iteration();
	}

	std::tuple<uint64, uint64, uint64> check_output_errors() {
		if (this->parameters_.generate == true) {
			return {0, 0, 0};
		}

		uint64 host_errors = 0;
		uint64 memory_errors = 0;
		uint64 relative_errors = 0;
		double min_diff = UINT32_MAX;

#pragma omp parallel for shared(host_errors, memory_errors, relative_errors, min_diff)
		for (uint32 i = 0; i < this->output_host_1.size(); i++) {
			auto check_flag = true;
			auto val_gold = this->gold_vector[i];

			auto val_output_1 = this->output_host_1[i];
			auto val_output_2 = this->output_host_2[i];
			auto val_output_3 = this->output_host_3[i];
			auto val_output = val_output_1;

			if ((val_output_1 != val_output_2)
					|| (val_output_1 != val_output_3)) {
#pragma omp critical
				{
					std::stringstream info_detail;
					info_detail.precision(PRECISION_PLACES);
					info_detail << std::scientific;
					info_detail << "m: [" << i << "], r0: " << val_output_1;
					info_detail << ", r1: " << val_output_2;
					info_detail << ", r2: " << val_output_3;
					info_detail << ", e: " << val_gold;

					if (this->parameters_.verbose && (host_errors < 10))
						std::cout << info_detail.str() << std::endl;
					this->log_.log_info_detail(info_detail.str());
					memory_errors++;
				}

				if ((val_output_1 != val_output_2)
						&& (val_output_2 != val_output_3)
						&& (val_output_1 != val_output_3)) {
					// All 3 values diverge
					if (val_output_1 == val_gold) {
						val_output = val_output_1;
					} else if (val_output_2 == val_gold) {
						val_output = val_output_2;
					} else if (val_output_3 == val_gold) {
						val_output = val_output_3;
					} else {
						// NO VALUE MATCHES THE GOLD AND ALL 3 DIVERGE!
						check_flag = false;
#pragma omp critical
						{
							std::stringstream info_detail;
							info_detail.precision(PRECISION_PLACES);
							info_detail << std::scientific;
							info_detail << "f: [" << i << "], r0: "
									<< val_output_1;
							info_detail << ", r1: " << val_output_2;
							info_detail << ", r2: " << val_output_3;
							info_detail << ", e: " << val_gold;

							if (this->parameters_.verbose && (host_errors < 10))
								std::cout << info_detail.str() << std::endl;
							this->log_.log_info_detail(info_detail.str());
							memory_errors++;
						}
					}
				} else if (val_output_2 == val_output_3) {
					// Only value 0 diverge
					val_output = val_output_2;
				} else if (val_output_1 == val_output_3) {
					// Only value 1 diverge
					val_output = val_output_1;
				} else if (val_output_1 == val_output_2) {
					// Only value 2 diverge
					val_output = val_output_1;
				}
			}

			//check the output with lower precision
			//if available
			double val_output_lower_precision =
					this->check_with_lower_precision(val_output, i,
							relative_errors);
			double val_output_bigger_precision = double(val_output);
#pragma omp critical
			{
				min_diff = std::min(min_diff,
						std::fabs(
								val_output_bigger_precision
										- val_output_lower_precision));
			}

			if ((val_gold != val_output
					|| this->cmp(val_output_lower_precision,
							val_output_bigger_precision)) && check_flag) {
#pragma omp critical
				{
					std::stringstream error_detail;
					error_detail.precision(PRECISION_PLACES);
					error_detail << "p: [" << i << "], r: " << std::scientific
							<< val_output << ", e: " << val_gold
							<< ", smaller_precision: "
							<< val_output_lower_precision;

					if (this->parameters_.verbose && (host_errors < 10))
						std::cout << error_detail.str() << std::endl;

					this->log_.log_error_detail(error_detail.str());
					host_errors++;
				}

			}
		}

//		std::cout << "MIN DIFFERENCE IN FLOAT "

		this->log_.update_errors(host_errors);
		this->log_.update_infos(memory_errors);

		if (host_errors != 0) {
			std::cout << "#";
		}

		if (memory_errors != 0) {
			std::cout << "M";
		}

		return {host_errors, memory_errors, relative_errors};
	}

	virtual inline double check_with_lower_precision(const real_t& val,
			const uint64& i, uint64& memory_errors) {
		return double(val);
	}

	inline bool cmp(double& lhs, double& rhs) {
		double diff = std::fabs(lhs - rhs);
		if (diff > ZERO_FLOAT) {
			return true;
		}
		return false;
	}

	uint64 check_which_one_is_right() {
		uint64 memory_errors = 0;
		uint64 nan_count = 0;
		uint64 inf_count = 0;
		uint64 zero_count = 0;

#pragma omp parallel for shared(memory_errors)
		for (uint32 i = 0; i < this->gold_vector.size(); i++) {
			auto val_output_1 = this->output_host_1[i];
			auto val_output_2 = this->output_host_2[i];
			auto val_output_3 = this->output_host_3[i];

			nan_count += std::isnan(val_output_1);
			inf_count += std::isinf(val_output_1);

			nan_count += std::isnan(val_output_2);
			inf_count += std::isinf(val_output_2);

			nan_count += std::isnan(val_output_3);
			inf_count += std::isinf(val_output_3);

			zero_count += (val_output_1 == 0.0);
			zero_count += (val_output_2 == 0.0);
			zero_count += (val_output_3 == 0.0);

			this->gold_vector[i] = val_output_1;
			if ((val_output_1 != val_output_2)
					|| (val_output_1 != val_output_3)) {
#pragma omp critical
				{
					memory_errors++;
				}

				if (val_output_2 == val_output_3) {
					// Only value 0 diverge
					this->gold_vector[i] = val_output_2;
				} else if (val_output_1 == val_output_3) {
					// Only value 1 diverge
					this->gold_vector[i] = val_output_1;
				} else if (val_output_1 == val_output_2) {
					// Only value 2 diverge
					this->gold_vector[i] = val_output_1;
				}
			}
		}

		return memory_errors;
	}

	void write_gold() {
		auto memory_errors = this->check_which_one_is_right();
		if (memory_errors != 0) {
			std::string err = "GOLDEN GENERATOR FAILED "
					+ std::to_string(memory_errors);
			fatalerror(err.c_str());
		}

		this->write_to_file(this->parameters_.gold_file, this->gold_vector);
	}

	void load_gold() {
		this->load_file_data(this->parameters_.gold_file, this->gold_vector);
	}

	void load_file_data(std::string path, std::vector<real_t>& array) {
		std::ifstream input(path, std::ios::binary);
		if (input.good()) {
			input.read(reinterpret_cast<char*>(array.data()),
					array.size() * sizeof(real_t));
		}
		input.close();
	}

	void write_to_file(std::string path, std::vector<real_t>& array) {
		std::ofstream output(path, std::ios::binary);
		if (output.good()) {
			output.write(reinterpret_cast<char*>(array.data()),
					array.size() * sizeof(real_t));
		}
		output.close();
	}

	virtual inline uint64 copy_data_back() {
		this->output_host_1 = this->output_dev_1.to_vector();
		this->output_host_2 = this->output_dev_2.to_vector();
		this->output_host_3 = this->output_dev_3.to_vector();
		return 0;
	}
};

#endif /* MICROBENCHMARK_H_ */