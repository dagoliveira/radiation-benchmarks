#include "include/cuda_utils.h"

#include "Parameters.h"
#include "common.h"

Parameters::Parameters(int argc, char** argv) :
		alpha(1), beta(0) {

	//getting alpha and beta
	this->alpha = rad::find_float_arg(argc, argv, "--alpha", 1);
	this->beta = rad::find_float_arg(argc, argv, "--beta", 0);
	this->use_cublas = rad::find_arg(argc, argv, "--use_cublas");
	this->use_cutlass = rad::find_arg(argc, argv, "--use_cutlass");

	this->generate = rad::find_arg(argc, argv, "--generate");

	this->size_matrices = rad::find_int_arg(argc, argv, "--size", 1024);

	this->iterations = rad::find_int_arg(argc, argv, "--iterations", 1);

	this->a_input_path = rad::find_char_arg(argc, argv, "--input_a",
			"./input_a.matrix");
	this->b_input_path = rad::find_char_arg(argc, argv, "--input_b",
			"./input_b.matrix");
	this->c_input_path = rad::find_char_arg(argc, argv, "--input_c",
			"./input_c.matrix");
	this->gold_inout_path = rad::find_char_arg(argc, argv, "--gold",
			"./gold.matrix");

	this->precision = rad::find_char_arg(argc, argv, "--precision", "float");

	this->dmr = rad::find_char_arg(argc, argv, "--dmr", "none");

	this->use_tensor_cores = rad::find_arg(argc, argv, "--tensor_cores");

	this->check_block = rad::find_int_arg(argc, argv, "--opnum", BLOCK_SIZE);

	this->verbose = rad::find_arg(argc, argv, "--verbose");

	this->triplicated = rad::find_arg(argc, argv, "--triplicated");

	this->check_input_existence = rad::find_arg(argc, argv, "--check_input_existence");

	if (this->generate) {
		this->iterations = 1;
	}else{
		// files must be there already
		this->check_input_existence = false;
	}


	if (this->use_cublas && this->use_cutlass) {
		std::cerr
				<< "Warning! Using --use_cublas and --use_cutlass at same time"
						" will override --use_cublas!\n";
		this->use_cublas = false;
	}

	std::string test_info = std::string(" iterations: ")
			+ std::to_string(this->iterations);

	test_info += " precision: " + this->precision;

	test_info += " matrix_n_dim: " + std::to_string(this->size_matrices);

	test_info += " triplicated: " + std::to_string(this->triplicated);

	test_info += " dmr: " + this->dmr;

	test_info += " use_tensorcores: " + std::to_string(this->use_tensor_cores);

	test_info += " checkblock: " + std::to_string(this->check_block);

	test_info += " alpha: " + std::to_string(this->alpha);
	test_info += " beta: " + std::to_string(this->beta);
	test_info += " use_cublas: " + std::to_string(this->use_cublas);
	test_info += " use_cutlass: " + std::to_string(this->use_cutlass);

	std::string app = "gemm_tensor_cores_" + this->precision;
	this->log = std::make_shared<rad::Log>(app, test_info);
}

std::ostream& operator<<(std::ostream& os, const Parameters& log_obj) {
	os << std::boolalpha;
	os << "Generate: " << log_obj.generate << std::endl;
	os << "A input path: " << log_obj.a_input_path << std::endl;
	os << "B input path: " << log_obj.b_input_path << std::endl;
	os << "C input path: " << log_obj.c_input_path << std::endl;
	os << "Gold in/out path: " << log_obj.gold_inout_path << std::endl;
	os << "Iterations: " << log_obj.iterations << std::endl;
	os << "Matrix size: " << log_obj.size_matrices << std::endl;
	os << "Precision: " << log_obj.precision << std::endl;
	os << "Verbose: " << log_obj.verbose << std::endl;
	os << "DMR type: " << log_obj.dmr << std::endl;
	os << "Tensor cores: " << log_obj.use_tensor_cores << std::endl;
	os << "Alpha: " << log_obj.alpha << std::endl;
	os << "Beta: " << log_obj.beta << std::endl;
	os << "DMR Block checking " << log_obj.check_block << std::endl;
	os << "Use cuBLAS: " << log_obj.use_cublas << std::endl;
	os << "LOGFILENAME: " << ::get_log_file_name();
	return os;
}

void Parameters::end_iteration() {
	this->log->end_iteration();
}

void Parameters::start_iteration() {
	this->log->start_iteration();
}

void Parameters::log_error(std::string error_detail) {
	this->log->log_error_detail(error_detail);
}

void Parameters::log_info(std::string info_detail) {
	this->log->log_info_detail(info_detail);
}

void Parameters::update_error_count(long error_count) {
	this->log->update_errors();
}

void Parameters::update_info_count(long info_count) {
	this->log->update_infos();
}

void Parameters::usage(char** argv){
		std::cout << "./" << argv[0]
				<< " --generate --gold <gold file, DEFAULT=./gold.matrix > \n"
						"--size <matrix size, DEFAULT=8192> \n"
						"--iterations <how many iterations, optional> \n"
						"--input_a <input A, DEFAUL=./input_a.matrix> \n"
						"--input_b <input B, DEFAUL=./input_b.matrix> \n"
						"--input_c <input C, DEFAUL=./input_c.matrix>  \n"
						"--precision <float/double, DEFAULT=float> \n"
						"--check_input_existence"
				<< std::endl;
}
