/*
 * Log.h
 *
 *  Created on: Oct 4, 2018
 *      Author: carol
 */

#ifndef LOG_H_
#define LOG_H_
#include <string>
#include <sys/time.h>

#ifdef LOGS
#include "log_helper.h"
#endif

#include <string>
#include "kernels.h"

class Log {
public:
	int iterations;
	bool verbose;
	std::string test_mode;

	Log(int argc, char** argv, Board device) {
		this->iterations = this->find_int_arg(argc, argv, "--iterations", 0);
		this->verbose = this->find_int_arg(argc, argv, "--verbose", 0);
		this->test_mode = this->find_char_arg(argc, argv, "--memtotest",
				"L1");

#ifdef LOGS
		std::string test_info = std::string(" iterations: ")
		+ std::to_string(this->iterations);

		test_info += " board: " + std::to_string(device);
		test_info += " test_mode: " + test_mode

		std::string app = test_mode + "Test";
		set_iter_interval_print(10);

		start_log_file(const_cast<char*>(app.c_str()),
				const_cast<char*>(test_info.c_str()));
#endif
	}

	virtual ~Log() {
#ifdef LOGS
		end_log_file();
#endif
	}

	void end_iteration_app() {
#ifdef LOGS
		end_iteration();
#endif
	}

	void start_iteration_app() {
#ifdef LOGS
		start_iteration();
#endif
	}

	void update_timestamp_app() {
#ifdef LOGS
		update_timestamp();
#endif
	}

	void log_error(std::string error_detail) {
#ifdef LOGS
		log_error_detail(const_cast<char*>(error_detail.c_str()));
#endif
	}

	void log_info(std::string info_detail) {
#ifdef LOGS
		log_info_detail(const_cast<char*>(info_detail.c_str()));
#endif
	}

	void update_error_count(long error_count) {
#ifdef LOGS
		if (error_count)
		log_error_count(error_count);
#endif
	}

	void update_info_count(long info_count) {
#ifdef LOGS
		if (info_count)
		log_info_count (info_count);
#endif
	}

	static double mysecond() {
		struct timeval tp;
		struct timezone tzp;
		int i = gettimeofday(&tp, &tzp);
		return ((double) tp.tv_sec + (double) tp.tv_usec * 1.e-6);
	}

	static void del_arg(int argc, char **argv, int index) {
		int i;
		for (i = index; i < argc - 1; ++i)
			argv[i] = argv[i + 1];
		argv[i] = 0;
	}

	static int find_int_arg(int argc, char **argv, std::string arg, int def) {
		int i;
		for (i = 0; i < argc - 1; ++i) {
			if (!argv[i])
				continue;
			if (std::string(argv[i]) == arg) {
				def = atoi(argv[i + 1]);
				del_arg(argc, argv, i);
				del_arg(argc, argv, i);
				break;
			}
		}
		return def;
	}

	static std::string find_char_arg(int argc, char **argv, std::string arg,
			std::string def) {
		int i;
		for (i = 0; i < argc - 1; ++i) {
			if (!argv[i])
				continue;
			if (std::string(argv[i]) == arg) {
				def = std::string(argv[i + 1]);
				del_arg(argc, argv, i);
				del_arg(argc, argv, i);
				break;
			}
		}
		return def;
	}
//
//	static int find_arg(int argc, char* argv[], std::string arg) {
//		int i;
//		for (i = 0; i < argc; ++i) {
//			if (!argv[i])
//				continue;
//			if (std::string(argv[i]) == arg) {
//				del_arg(argc, argv, i);
//				return 1;
//			}
//		}
//		return 0;
//	}
//
//	static float find_float_arg(int argc, char **argv, char *arg, float def) {
//		int i;
//		for (i = 0; i < argc - 1; ++i) {
//			if (!argv[i])
//				continue;
//			if (0 == strcmp(argv[i], arg)) {
//				def = atof(argv[i + 1]);
//				del_arg(argc, argv, i);
//				del_arg(argc, argv, i);
//				break;
//			}
//		}
//		return def;
//	}

};

#endif /* LOG_H_ */
