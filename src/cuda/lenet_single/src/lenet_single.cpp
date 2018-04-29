#ifdef WITH_PYTHON_LAYER
#include <boost/python.hpp>
namespace bp = boost::python;
#endif

#include <gflags/gflags.h>
#include <glog/logging.h>
#include <map>
#include <vector>
#include <boost/algorithm/string.hpp>

#include "caffe/caffe.hpp"
#include "caffe/util/signal_handler.h"
#include "caffe/util/bbox_util.hpp"

// For radiation tests
#include "logs_processing.h"

using caffe::TBlob;
using caffe::Blob;
using caffe::Caffe;
using caffe::Net;
using caffe::LayerBase;
using caffe::Solver;
using caffe::shared_ptr;
using caffe::string;
using caffe::Timer;
using caffe::vector;
using std::ostringstream;

LogsProcessing* global_log;

DEFINE_string(gpu, "",
		"Optional; run in GPU mode on given device IDs separated by ', '."
		"Use '-gpu all' to run on all available GPUs. The effective training "
		"batch size is multiplied by the number of devices.");
DEFINE_string(solver, "",
		"The solver definition protocol buffer text file.");
DEFINE_string(model, "",
		"The model definition protocol buffer text file.");
DEFINE_string(phase, "",
		"Optional; network phase (TRAIN or TEST). Only used for 'time'.");
DEFINE_int32(level, 0,
		"Optional; network level.");
DEFINE_string(stage, "",
		"Optional; network stages (not to be confused with phase), "
		"separated by ','.");
DEFINE_string(snapshot, "",
		"Optional; the snapshot solver state to resume training.");
DEFINE_string(weights, "",
		"Optional; the pretrained weights to initialize finetuning, "
		"separated by ', '. Cannot be set simultaneously with snapshot.");
DEFINE_int32(iterations, 50,
		"The number of iterations to run.");
DEFINE_string(sigint_effect, "stop",
		"Optional; action to take when a SIGINT signal is received: "
		"snapshot, stop or none.");
DEFINE_string(sighup_effect, "snapshot",
		"Optional; action to take when a SIGHUP signal is received: "
		"snapshot, stop or none.");
DEFINE_string(ap_version, "11point",
		"Average Precision type for object detection");
DEFINE_bool(show_per_class_result, true,
		"Show per class result for object detection");

// A simple registry for caffe commands.
typedef int (*BrewFunction)();
typedef std::map<caffe::string, BrewFunction> BrewMap;
BrewMap g_brew_map;

#define RegisterBrewFunction(func) \
namespace { \
class __Registerer_##func { \
 public: /* NOLINT */ \
  __Registerer_##func() { \
    g_brew_map[#func] = &func; \
  } \
}; \
__Registerer_##func g_registerer_##func; \
}

static BrewFunction GetBrewFunction(const caffe::string& name) {
	if (g_brew_map.count(name)) {
		return g_brew_map[name];
	} else {
		LOG(ERROR) << "Available caffe actions:";
		for (BrewMap::iterator it = g_brew_map.begin(); it != g_brew_map.end();
				++it) {
			LOG(ERROR) << "\t" << it->first;
		}
		LOG(FATAL) << "Unknown action: " << name;
		return NULL;  // not reachable, just to suppress old compiler warnings.
	}
}

// Parse GPU ids or use all available devices
static void get_gpus(vector<int>* gpus) {
	if (FLAGS_gpu == "all") {
		const int count = Caffe::device_count();
		for (int i = 0; i < count; ++i) {
			gpus->push_back(i);
		}
	} else if (FLAGS_gpu.size()) {
		vector < string > strings;
		boost::split(strings, FLAGS_gpu, boost::is_any_of(", "));
		for (int i = 0; i < strings.size(); ++i) {
			gpus->push_back(boost::lexical_cast<int>(strings[i]));
		}
	} else {
		CHECK_EQ(gpus->size(), 0);
	}
}

// Parse phase from flags
caffe::Phase get_phase_from_flags(caffe::Phase default_value) {
	if (FLAGS_phase == "")
		return default_value;
	if (FLAGS_phase == "TRAIN")
		return caffe::TRAIN;
	if (FLAGS_phase == "TEST")
		return caffe::TEST;
	LOG(FATAL) << "phase must be \"TRAIN\" or \"TEST\"";
	return caffe::TRAIN;  // Avoid warning
}

// Parse stages from flags
vector<string> get_stages_from_flags() {
	vector < string > stages;
	boost::split(stages, FLAGS_stage, boost::is_any_of(","));
	return stages;
}

// caffe commands to call by
//     caffe <command> <args>
//
// To add a command, define a function "int command()" and register it with
// RegisterBrewFunction(action);

// Device Query: show diagnostic information for a GPU device.
int device_query() {
	LOG(INFO) << "Querying GPUs " << FLAGS_gpu;
	vector<int> gpus;
	get_gpus(&gpus);
	for (int i = 0; i < gpus.size(); ++i) {
		caffe::Caffe::SetDevice(gpus[i]);
		std::cout << caffe::Caffe::DeviceQuery();
	}
	return 0;
}
RegisterBrewFunction(device_query);

// Load the weights from the specified caffemodel(s) into the train and
// test nets.
void CopyLayers(caffe::Solver* solver, const std::string& model_list) {
	std::vector < std::string > model_names;
	boost::split(model_names, model_list, boost::is_any_of(", "));
	for (int i = 0; i < model_names.size(); ++i) {
		LOG(INFO) << "Finetuning from " << model_names[i];
		solver->net()->CopyTrainedLayersFrom(model_names[i]);
		for (int j = 0; j < solver->test_nets().size(); ++j) {
			solver->test_nets()[j]->CopyTrainedLayersFrom(model_names[i]);
		}
	}
}

// Translate the signal effect the user specified on the command-line to the
// corresponding enumeration.
caffe::SolverAction::Enum GetRequestedAction(const std::string& flag_value) {
	if (flag_value == "stop") {
		return caffe::SolverAction::STOP;
	}
	if (flag_value == "snapshot") {
		return caffe::SolverAction::SNAPSHOT;
	}
	if (flag_value == "none") {
		return caffe::SolverAction::NONE;
	}
	LOG(FATAL) << "Invalid signal effect \"" << flag_value
			<< "\" was specified";
	return caffe::SolverAction::NONE;
}

// Train / Finetune a model.
int train() {
	CHECK_GT(FLAGS_solver.size(), 0) << "Need a solver definition to train.";
	CHECK(!FLAGS_snapshot.size() || !FLAGS_weights.size())
			<< "Give a snapshot to resume training or weights to finetune "
					"but not both.";
	vector < string > stages = get_stages_from_flags();

	caffe::SolverParameter solver_param =
			caffe::ReadSolverParamsFromTextFileOrDie(FLAGS_solver);

	solver_param.mutable_train_state()->set_level(FLAGS_level);
	for (int i = 0; i < stages.size(); i++) {
		solver_param.mutable_train_state()->add_stage(stages[i]);
	}

	// If the gpus flag is not provided, allow the mode and device to be set
	// in the solver prototxt.
	if (FLAGS_gpu.size() == 0 && solver_param.has_solver_mode()
			&& solver_param.solver_mode()
					== caffe::SolverParameter_SolverMode_GPU) {
		if (solver_param.has_device_id()) {
			FLAGS_gpu = std::to_string(solver_param.device_id());
		} else {  // Set default GPU if unspecified
			FLAGS_gpu = std::to_string(0);
		}
	}

	// Read flags for list of GPUs
	vector<int> gpus;
	get_gpus(&gpus);

	// Set mode and device id[s]
	if (gpus.size() == 0) {
		LOG(INFO) << "Use CPU.";
		Caffe::set_mode(Caffe::CPU);
	} else {
		ostringstream s;
		for (int i = 0; i < gpus.size(); ++i) {
			s << (i ? ", " : "") << gpus[i];
		}

		caffe::GPUMemory::Scope gpu_memory_scope(gpus);

		LOG(INFO) << "Using GPUs " << s.str();
		cudaDeviceProp device_prop;
		for (int i = 0; i < gpus.size(); ++i) {
			cudaGetDeviceProperties(&device_prop, gpus[i]);
			LOG(INFO) << "GPU " << gpus[i] << ": " << device_prop.name;
		}
		CUDA_CHECK(cudaSetDevice(gpus[0]));
		Caffe::SetDevice(gpus[0]);
		solver_param.set_device_id(gpus[0]);
		Caffe::set_mode(Caffe::GPU);
		Caffe::set_gpus(gpus);
		Caffe::set_solver_count(gpus.size());
		CHECK_EQ(gpus.size(), Caffe::solver_count());
	}

	caffe::SignalHandler signal_handler(
			GetRequestedAction (FLAGS_sigint_effect),
			GetRequestedAction (FLAGS_sighup_effect));

	shared_ptr < caffe::Solver
			> solver(
					caffe::SolverRegistry::CreateSolver(solver_param, nullptr,
							0));
	solver->SetActionFunction(signal_handler.GetActionFunction());

	if (FLAGS_snapshot.size()) {
		LOG(INFO) << "Resuming from " << FLAGS_snapshot;
		solver->Restore(FLAGS_snapshot.c_str());
	} else if (FLAGS_weights.size()) {
		CopyLayers(solver.get(), FLAGS_weights);
	}

	if (gpus.size() > 1) {
		Caffe::set_solver_count(gpus.size());
		caffe::P2PManager p2p_mgr(solver, gpus.size(), solver->param());
		p2p_mgr.Run(gpus);
	} else {
		LOG(INFO) << "Starting Optimization";

		solver->Solve();

		if (gpus.size() == 1) {
			std::ostringstream os;
			os.precision(4);
			solver->perf_report(os, gpus[0]);
			LOG(INFO) << os.str();
		}
	}
	LOG(INFO) << "Optimization Done in " << Caffe::time_from_init();
	return 0;
}
RegisterBrewFunction(train);

// Test: score a model.
int test() {
	CHECK_GT(FLAGS_model.size(), 0) << "Need a model definition to score.";
	CHECK_GT(FLAGS_weights.size(), 0) << "Need model weights to score.";
	vector < string > stages = get_stages_from_flags();

	// Read flags for list of GPUs
	vector<int> gpus;
	get_gpus(&gpus);
	while (gpus.size() > 1) {
		// Only use one GPU
		LOG(INFO) << "Not using GPU #" << gpus.back()
				<< " for single-GPU function";
		gpus.pop_back();
	}
	if (gpus.size() > 0) {
		Caffe::SetDevice(gpus[0]);
	}
	caffe::GPUMemory::Scope gpu_memory_scope(gpus);

	// Set mode and device id
	if (gpus.size() != 0) {
		LOG(INFO) << "Use GPU with device ID " << gpus[0];
		cudaDeviceProp device_prop;
		cudaGetDeviceProperties(&device_prop, gpus[0]);
		LOG(INFO) << "GPU device name: " << device_prop.name;
		Caffe::set_mode(Caffe::GPU);
	} else {
		LOG(INFO) << "Use CPU.";
		Caffe::set_mode(Caffe::CPU);
	}

	// Instantiate the caffe net.
	Net caffe_net(FLAGS_model, caffe::TEST, 0U, nullptr, nullptr, false,
			FLAGS_level, &stages);
	caffe_net.CopyTrainedLayersFrom(FLAGS_weights);
	LOG(INFO) << "Running for " << FLAGS_iterations << " iterations.";

	vector<int> test_score_output_id;
	vector<float> test_score;
	float loss = 0;
	for (int i = 0; i < FLAGS_iterations; ++i) {
		float iter_loss;
		const vector<Blob*>& result = caffe_net.Forward(&iter_loss);
		loss += iter_loss;
		int idx = 0;
		for (int j = 0; j < result.size(); ++j) {
			const float* result_vec = result[j]->cpu_data<float>();
			for (int k = 0; k < result[j]->count(); ++k, ++idx) {
				const float score = result_vec[k];
				if (i == 0) {
					test_score.push_back(score);
					test_score_output_id.push_back(j);
				} else {
					test_score[idx] += score;
				}
				const std::string& output_name =
						caffe_net.blob_names()[caffe_net.output_blob_indices()[j]];
				LOG(INFO) << "Batch " << i << ", " << output_name << " = "
						<< score;
			}
		}
	}
	loss /= FLAGS_iterations;
	LOG(INFO) << "Loss: " << loss;
	for (int i = 0; i < test_score.size(); ++i) {
		const std::string& output_name =
				caffe_net.blob_names()[caffe_net.output_blob_indices()[test_score_output_id[i]]];
		const float loss_weight =
				caffe_net.blob_loss_weights()[caffe_net.output_blob_indices()[test_score_output_id[i]]];
		std::ostringstream loss_msg_stream;
		const float mean_score = test_score[i] / FLAGS_iterations;
		if (loss_weight) {
			loss_msg_stream << " (* " << loss_weight << " = "
					<< (loss_weight * mean_score) << " loss)";
		}
		LOG(INFO) << output_name << " = " << mean_score
				<< loss_msg_stream.str();
	}
	return 0;
}
RegisterBrewFunction(test);

// Test: score a detection model.
int test_detection() {

	typedef float Dtype;
	CHECK_GT(FLAGS_model.size(), 0) << "Need a model definition to score.";
	CHECK_GT(FLAGS_weights.size(), 0) << "Need model weights to score.";

	// Read flags for list of GPUs
	vector<int> gpus;
	get_gpus(&gpus);
	while (gpus.size() > 1) {
		// Only use one GPU
		LOG(INFO) << "Not using GPU #" << gpus.back()
				<< " for single-GPU function";
		gpus.pop_back();
	}
	if (gpus.size() > 0) {
		Caffe::SetDevice(gpus[0]);
	}
	caffe::GPUMemory::Scope gpu_memory_scope(gpus);

	// Set mode and device id
	if (gpus.size() != 0) {
		LOG(INFO) << "Use GPU with device ID " << gpus[0];
		cudaDeviceProp device_prop;
		cudaGetDeviceProperties(&device_prop, gpus[0]);
		LOG(INFO) << "GPU device name: " << device_prop.name;
		Caffe::set_mode(Caffe::GPU);
	} else {
		LOG(INFO) << "Use CPU.";
		Caffe::set_mode(Caffe::CPU);
	}

	// Instantiate the caffe net.
	Net caffe_net(FLAGS_model, caffe::TEST, 0U);
	caffe_net.CopyTrainedLayersFrom(FLAGS_weights);

	LOG(INFO) << "Running for " << FLAGS_iterations << " iterations.";
	for (int rad_iterations = 0; rad_iterations < global_log->iterations;
			rad_iterations++) {

		std::map<int, std::map<int, vector<std::pair<float, int> > > > all_true_pos;
		std::map<int, std::map<int, vector<std::pair<float, int> > > > all_false_pos;
		std::map<int, std::map<int, int> > all_num_pos;

		vector<int> test_score_output_id;
		vector<float> test_score;
		float loss = 0;
		for (int i = 0; i < FLAGS_iterations; ++i) {
			float iter_loss;
			const vector<Blob*>& result = caffe_net.Forward(&iter_loss);
			loss += iter_loss;
			int idx = 0;
			for (int j = 0; j < result.size(); ++j) {
				const float* result_vec = result[j]->cpu_data<float>();
				for (int k = 0; k < result[j]->count(); ++k, ++idx) {
					const float score = result_vec[k];
					if (i == 0) {
						test_score.push_back(score);
						test_score_output_id.push_back(j);
					} else {
						test_score[idx] += score;
					}
					const std::string& output_name =
							caffe_net.blob_names()[caffe_net.output_blob_indices()[j]];
					LOG(INFO) << "Batch " << i << ", " << output_name << " = "
							<< score;
				}
			}

			//To compute mAP
			for (int j = 0; j < result.size(); ++j) {
				CHECK_EQ(result[j]->width(), 5);
				const Dtype* result_vec = result[j]->cpu_data<Dtype>();
				int num_det = result[j]->height();
				for (int k = 0; k < num_det; ++k) {
					int item_id = static_cast<int>(result_vec[k * 5]);
					int label = static_cast<int>(result_vec[k * 5 + 1]);
					if (item_id == -1) {
						// Special row of storing number of positives for a label.
						if (all_num_pos[j].find(label)
								== all_num_pos[j].end()) {
							all_num_pos[j][label] =
									static_cast<int>(result_vec[k * 5 + 2]);
						} else {
							all_num_pos[j][label] +=
									static_cast<int>(result_vec[k * 5 + 2]);
						}
					} else {
						// Normal row storing detection status.
						float score = result_vec[k * 5 + 2];
						int tp = static_cast<int>(result_vec[k * 5 + 3]);
						int fp = static_cast<int>(result_vec[k * 5 + 4]);
						if (tp == 0 && fp == 0) {
							// Ignore such case. It happens when a detection bbox is matched to
							// a difficult gt bbox and we don't evaluate on difficult gt bbox.
							continue;
						}
						all_true_pos[j][label].push_back(
								std::make_pair(score, tp));
						all_false_pos[j][label].push_back(
								std::make_pair(score, fp));
					}
				}
			}
		}

		loss /= FLAGS_iterations;
		LOG(INFO) << "Loss: " << loss;

		for (int i = 0; i < test_score.size(); ++i) {
			int test_score_output_id_value = test_score_output_id[i];
			const vector<int>& output_blob_indices =
					caffe_net.output_blob_indices();
			const vector<string>& blob_names = caffe_net.blob_names();
			const vector<float>& blob_loss_weights =
					caffe_net.blob_loss_weights();
			if (test_score_output_id_value < output_blob_indices.size()) {
				int blob_index = output_blob_indices[test_score_output_id_value];
				if (blob_index < blob_names.size()
						&& blob_index < blob_loss_weights.size()) {
					const std::string& output_name = blob_names[blob_index];
					const float loss_weight = blob_loss_weights[blob_index];
					std::ostringstream loss_msg_stream;
					const float mean_score = test_score[i] / FLAGS_iterations;
					if (loss_weight) {
						loss_msg_stream << " (* " << loss_weight << " = "
								<< (loss_weight * mean_score) << " loss)";
					}
					LOG(INFO) << output_name << " = " << mean_score
							<< loss_msg_stream.str();
				}
			}
		}

		//To compute mAP
		for (int i = 0; i < all_true_pos.size(); ++i) {
			if (all_true_pos.find(i) == all_true_pos.end()) {
				LOG(FATAL) << "Missing output_blob true_pos: " << i;
			}
			const std::map<int, vector<std::pair<float, int> > >& true_pos =
					all_true_pos.find(i)->second;
			if (all_false_pos.find(i) == all_false_pos.end()) {
				LOG(FATAL) << "Missing output_blob false_pos: " << i;
			}
			const std::map<int, vector<std::pair<float, int> > >& false_pos =
					all_false_pos.find(i)->second;
			if (all_num_pos.find(i) == all_num_pos.end()) {
				LOG(FATAL) << "Missing output_blob num_pos: " << i;
			}
			const std::map<int, int>& num_pos = all_num_pos.find(i)->second;
			std::map<int, float> APs;
			float mAP = 0.;
			// Sort true_pos and false_pos with descend scores.
			for (std::map<int, int>::const_iterator it = num_pos.begin();
					it != num_pos.end(); ++it) {
				int label = it->first;
				int label_num_pos = it->second;
				if (true_pos.find(label) == true_pos.end()) {
					LOG(WARNING) << "Missing true_pos for label: " << label;
					continue;
				}
				const vector<std::pair<float, int> >& label_true_pos =
						true_pos.find(label)->second;
				if (false_pos.find(label) == false_pos.end()) {
					LOG(WARNING) << "Missing false_pos for label: " << label;
					continue;
				}
				const vector<std::pair<float, int> >& label_false_pos =
						false_pos.find(label)->second;
				vector<float> prec, rec;
				caffe::ComputeAP(label_true_pos, label_num_pos, label_false_pos,
						FLAGS_ap_version, &prec, &rec, &(APs[label]));
				mAP += APs[label];
				if (FLAGS_show_per_class_result) {
					LOG(INFO) << "class AP " << label << ": " << APs[label];
				}
			}
			mAP /= num_pos.size();
			const int output_blob_index = caffe_net.output_blob_indices()[i];
			const string& output_name =
					caffe_net.blob_names()[output_blob_index];
			LOG(INFO) << "Test net output mAP #" << i << ": " << output_name
					<< " = " << mAP;
		}
	}
	return 0;
}
RegisterBrewFunction(test_detection);

// Time: benchmark the execution time of a model.
int time() {
	CHECK_GT(FLAGS_model.size(), 0) << "Need a model definition to time.";
	caffe::Phase phase = get_phase_from_flags(caffe::TRAIN);
	vector < string > stages = get_stages_from_flags();

	vector<int> gpus;
	// Read flags for list of GPUs
	get_gpus(&gpus);
	while (gpus.size() > 1) {
		// Only use one GPU
		LOG(INFO) << "Not using GPU #" << gpus.back()
				<< " for single-GPU function";
		gpus.pop_back();
	}
	if (gpus.size() > 0) {
		Caffe::SetDevice(gpus[0]);
	}
	caffe::GPUMemory::Scope gpu_memory_scope(gpus);
	// Set mode and device_id
	if (gpus.size() != 0) {
		LOG(INFO) << "Use GPU with device ID " << gpus[0];
		cudaDeviceProp device_prop;
		cudaGetDeviceProperties(&device_prop, gpus[0]);
		LOG(INFO) << "GPU " << gpus[0] << ": " << device_prop.name;
		Caffe::set_mode(Caffe::GPU);
	} else {
		LOG(INFO) << "Use CPU.";
		Caffe::set_mode(Caffe::CPU);
	}
	const int kInitIterations = 5;

	caffe::SolverParameter solver_param;
	caffe::ReadNetParamsFromTextFileOrDie(FLAGS_model,
			solver_param.mutable_net_param());
	solver_param.set_max_iter(kInitIterations);
	solver_param.set_lr_policy("fixed");
	solver_param.set_snapshot_after_train(false);
	solver_param.set_base_lr(0.01F);
	solver_param.set_random_seed(1371LL);
	solver_param.set_test_interval(FLAGS_iterations + 1);
	solver_param.set_display(0);

	solver_param.mutable_train_state()->set_level(FLAGS_level);
	for (int i = 0; i < stages.size(); i++) {
		solver_param.mutable_train_state()->add_stage(stages[i]);
	}
	solver_param.mutable_net_param()->mutable_state()->set_phase(phase);

	shared_ptr < Solver
			> solver(caffe::SolverRegistry::CreateSolver(solver_param));
	shared_ptr < Net > caffe_net = solver->net();

	// Do a number of clean forward and backward pass,
	// so that memory allocation are done,
	// and future iterations will be more stable.
	Timer init_timer;
	Timer forward_timer;
	Timer backward_timer;
	double forward_time = 0.0;
	double backward_time = 0.0;
	LOG(INFO) << "Initialization for " << kInitIterations << " iterations.";
	// Note that for the speed benchmark, we will assume that the network does
	// not take any input blobs.
	LOG(INFO) << "Performing initial Forward/Backward";
	const vector<shared_ptr<LayerBase> >& layers = caffe_net->layers();
	const vector<vector<Blob*> >& bottom_vecs = caffe_net->bottom_vecs();
	const vector<vector<Blob*> >& top_vecs = caffe_net->top_vecs();
	const vector<vector<bool> >& bottom_need_backward =
			caffe_net->bottom_need_backward();
	init_timer.Start();
	solver->Step(kInitIterations);
	double init_time = init_timer.MilliSeconds();
	LOG(INFO) << "Initial Forward/Backward complete";
	LOG(INFO) << "Average Initialization Forward/Backward pass: "
			<< init_time / kInitIterations << " ms.";

	LOG(INFO) << "*** Benchmark begins ***";
	LOG(INFO) << "Testing for " << FLAGS_iterations << " iterations.";
	Timer total_timer;
	total_timer.Start();
	Timer timer;
	std::vector<double> forward_time_per_layer(layers.size(), 0.0);
	std::vector<double> backward_time_per_layer(layers.size(), 0.0);
	forward_time = 0.0;
	backward_time = 0.0;
	for (int j = 0; j < FLAGS_iterations; ++j) {
		Timer iter_timer;
		iter_timer.Start();
		forward_timer.Start();
		for (int i = 0; i < layers.size(); ++i) {
			timer.Start();
			layers[i]->Forward(bottom_vecs[i], top_vecs[i]);
			forward_time_per_layer[i] += timer.MicroSeconds();
		}
		forward_time += forward_timer.MicroSeconds();
		backward_timer.Start();
		for (int i = layers.size() - 1; i >= 0; --i) {
			timer.Start();
			layers[i]->Backward(top_vecs[i], bottom_need_backward[i],
					bottom_vecs[i]);
			backward_time_per_layer[i] += timer.MicroSeconds();
		}
		backward_time += backward_timer.MicroSeconds();
		LOG(INFO) << "Iteration: " << j + 1 << " forward-backward time: "
				<< iter_timer.MilliSeconds() << " ms.";
	}
	LOG(INFO) << "Average time per layer: ";
	for (int i = 0; i < layers.size(); ++i) {
		const caffe::string& layername = layers[i]->layer_param().name();
		LOG(INFO) << std::setfill(' ') << std::setw(10) << layername
				<< "\tforward: "
				<< forward_time_per_layer[i] / 1000 / FLAGS_iterations
				<< " ms.";
		LOG(INFO) << std::setfill(' ') << std::setw(10) << layername
				<< "\tbackward: "
				<< backward_time_per_layer[i] / 1000 / FLAGS_iterations
				<< " ms.";
	}
	total_timer.Stop();
	LOG(INFO) << "Average Forward pass: "
			<< forward_time / 1000 / FLAGS_iterations << " ms.";
	LOG(INFO) << "Average Backward pass: "
			<< backward_time / 1000 / FLAGS_iterations << " ms.";
	LOG(INFO) << "Average Forward-Backward: "
			<< total_timer.MilliSeconds() / FLAGS_iterations << " ms.";
	LOG(INFO) << "Total Time: " << total_timer.MilliSeconds() << " ms.";
	LOG(INFO) << "*** Benchmark ends ***";
	return 0;
}
RegisterBrewFunction(time);

//char** pre_process_argv(int argc, char** argv, int radiation_parameters_size) {
//	char** ret_args_copy = (char**)malloc(argc * sizeof(char));
//	for (int i = 0; i < argc - radiation_parameters_size; i++) {
//		ret_args_copy[i] = argv[i];
//	}
//	return ret_args_copy;
//}

int main(int argc, char** argv) {
	// Print output to stderr (while still logging).
	FLAGS_alsologtostderr = 1;
	// Set version
	gflags::SetVersionString (AS_STRING(CAFFE_VERSION));

	// Usage message.
gflags	::SetUsageMessage("command line brew\n"
			"usage: caffe <command> <args>\n\n"
			"commands:\n"
			"  train           train or finetune a model\n"
			"  test            score a model\n"
			"  device_query    show GPU diagnostic information\n"
			"  time            benchmark model execution time");

	std::ostringstream os;
	os << std::endl;
	for (int n = 0; n < argc; ++n) {
		os << "[" << n << "]: " << argv[n] << std::endl;
	}

//	[0]: ./lenet
//	[1]: test
//	[2]: -model=/home/carol/radiation-benchmarks/data/lenet/lenet_train_test.prototxt
//	[3]: -weights=/home/carol/radiation-benchmarks/data/lenet/single_iter_10000.caffemodel
//	[4]: 1000
//	[5]: 1
//	[6]: /home/carol/radiation-benchmarks/data/lenet/gold_test.csv

	//I will pass in the following order
	// to not to  crash the application
	// after caffe parameters this comes
	// <rad iterations> <generate or not> <gold path>
	// Run tool or show usage.
	int argc_copy = argc - RADIATION_PARAMETERS;
	if (argc > 4) {
		char** argv_copy = (char**) malloc(
				(argc - RADIATION_PARAMETERS) * sizeof(char*));
		int i;
		for (i = 0; i < argc - RADIATION_PARAMETERS; i++) {
			argv_copy[i] = argv[i];
		}
		std::string prototxt = std::string(argv[2]);
		std::string weights = std::string(argv[3]);
		int iterations = atoi(argv[i++]);
		bool generate = atoi(argv[i++]);
		std::string gold_path = std::string(argv[i++]);

		LOG(INFO) << prototxt << " " << weights << " " << iterations << " "
				<< generate << " " << generate << std::endl;
		global_log = new LogsProcessing("lenetSingleCUDA", generate, gold_path,
				weights, prototxt, iterations);
		caffe::GlobalInit(&argc_copy, &argv_copy);
	} else {
		caffe::GlobalInit(&argc, &argv);
	}

	vector<int> gpus;
	get_gpus(&gpus);
	Caffe::SetDevice(gpus.size() > 0 ? gpus[0] : 0);
	Caffe::set_gpus(gpus);

	LOG(INFO) << "This is NVCaffe " << Caffe::caffe_version() << " started at "
			<< Caffe::start_time();
	LOG(INFO) << "CuDNN version: " << Caffe::cudnn_version();
	LOG(INFO) << "CuBLAS version: " << Caffe::cublas_version();
	LOG(INFO) << "CUDA version: " << Caffe::cuda_version();
	LOG(INFO) << "CUDA driver version: " << Caffe::cuda_driver_version();
	LOG(INFO) << "Arguments: " << os.str();

	if (argc > 4) {
		delete global_log;
	}

	if (argc_copy == 2) {
		return GetBrewFunction(caffe::string(argv[1]))();
	} else {
		gflags::ShowUsageWithFlagsRestrict(argv[0], "tools/caffe");
	}

}
