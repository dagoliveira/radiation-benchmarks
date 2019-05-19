/*
 * Parameters.cpp
 *
 *  Created on: 18/05/2019
 *      Author: fernando
 */

#include "Parameters.h"
// Helper functions
#include "helper_cuda.h"
#include "helper_string.h"

#ifndef DEFAULT_SIM_TIME
#define DEFAULT_SIM_TIME 10000
#endif

std::unordered_map<std::string, REDUNDANCY> red = {
//NONE
		{ "none", NONE },
		//DMR
		{ "dmr", DMR },
		// DMRMIXED
		{ "dmrmixed", DMRMIXED }, };

std::unordered_map<std::string, PRECISION> pre = {
//HALF
		{ "half", HALF },
		//SINGLE
		{ "single", SINGLE },
		// DOUBLE
		{ "double", DOUBLE }, };

Parameters::Parameters(int argc, char** argv) {
	this->nstreams = 1;
	this->sim_time = DEFAULT_SIM_TIME;
	this->pyramid_height = 1;
	this->setup_loops = 10000000;
	this->verbose = 0;
	this->fault_injection = 0;
	this->generate = 0;

	this->precision = SINGLE;
	this->redundancy = NONE;

	if (argc < 2) {
		usage(argc, argv);
		exit(EXIT_FAILURE);
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "precision")) {
		char* precision = nullptr;
		getCmdLineArgumentString(argc, (const char **) argv, "precision",
				&precision);
		if (precision) {
			this->precision = pre[std::string(precision)];
		}
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "redundancy")) {
		char* redundancy = nullptr;
		getCmdLineArgumentString(argc, (const char **) argv, "redundancy",
				&redundancy);
		if (redundancy) {
			this->redundancy = red[std::string(redundancy)];
		}
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "size")) {
		this->grid_cols = getCmdLineArgumentInt(argc, (const char **) argv,
				"size");
		this->grid_rows = this->grid_cols;

		if ((this->grid_cols <= 0) || (this->grid_cols % 16 != 0)) {
			std::cerr << "Invalid input size given on the command-line: "
					<< this->grid_cols << std::endl;
			exit(EXIT_FAILURE);
		}
	} else {
		usage(argc, argv);
		exit(EXIT_FAILURE);
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "generate")) {
		this->generate = true;
		std::cout
				<< "Output will be written to file. Only stream #0 output will be considered."
				<< std::endl;
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "sim_time")) {
		this->sim_time = getCmdLineArgumentInt(argc, (const char **) argv,
				"sim_time");

		if (this->sim_time < 1) {
			std::cerr << "Invalid sim_time given on the command-line: "
					<< this->sim_time << std::endl;
			exit(EXIT_FAILURE);
		}
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "input_temp")) {
		char* tfile_ = nullptr;
		getCmdLineArgumentString(argc, (const char **) argv, "input_temp",
				&tfile_);
		if (tfile_) {
			this->tfile = std::string(tfile_);
		}
	} else {
		this->tfile = "temp_" + std::to_string(this->grid_rows);
		std::cout << "Using default input_temp path: " << this->tfile
				<< std::endl;

	}

	if (checkCmdLineFlag(argc, (const char **) argv, "input_power")) {
		char *pfile_ = nullptr;
		getCmdLineArgumentString(argc, (const char **) argv, "input_power",
				&pfile_);
		if (pfile_) {
			this->pfile = std::string(pfile_);
		}
	} else {
		this->pfile = "power_" + std::to_string(this->grid_rows);
		std::cout << "Using default input_power path: " << this->pfile
				<< std::endl;

	}

	if (checkCmdLineFlag(argc, (const char **) argv, "gold_temp")) {
		char *ofile_ = nullptr;
		getCmdLineArgumentString(argc, (const char **) argv, "gold_temp",
				&ofile_);
		if (ofile_) {
			this->ofile = std::string(ofile_);
		}
	} else {
		this->ofile = "gold_temp_" + this->test_precision_description + "_"
				+ std::to_string(this->grid_rows) + "_"
				+ std::to_string(this->sim_time);
		std::cout << "Using default gold path: " << this->ofile << std::endl;
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "iterations")) {
		this->setup_loops = getCmdLineArgumentInt(argc, (const char **) argv,
				"iterations");
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "streams")) {
		this->nstreams = getCmdLineArgumentInt(argc, (const char **) argv,
				"streams");
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "verbose")) {
		this->verbose = 1;
	}

	if (checkCmdLineFlag(argc, (const char **) argv, "debug")) {
		this->fault_injection = true;
		std::cout << "!! Will be injected an input error\n";
	}

}

Parameters::Parameters() {
	this->nstreams = 1;
	this->sim_time = DEFAULT_SIM_TIME;
	this->pyramid_height = 1;
	this->setup_loops = 10000000;
	this->verbose = 0;
	this->fault_injection = 0;
	this->generate = 0;

	this->precision = SINGLE;
	this->redundancy = NONE;
	this->grid_cols = this->grid_rows = 0;
}

void Parameters::usage(int argc, char** argv) {
	std::cout << "Usage: " << argv[0]
			<< " [-size=N] [-generate] [-sim_time=N] [-input_temp=<path>] [-input_power=<path>] "
					"[-gold_temp=<path>] [-iterations=N] [-streams=N] [-debug] [-verbose] [-redundancy=<redundancy>] [-precision=<precision>] \n";

}

Parameters::~Parameters() {}