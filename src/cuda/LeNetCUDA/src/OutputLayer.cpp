/*
 * OutputLayer.cpp
 *
 *  Created on: 05/06/2017
 *      Author: fernando
 */

#include "OutputLayer.h"
#include "Util.h"
#define L1_LAMBDA  0.0000001
#define L2_LAMBDA  0.00000001

#ifdef GPU

void OutputLayer::forward() {
	exp_y_vec.clear();
	exp_y_vec.resize(this->in_depth_);

	float *exp_y_vec = this->exp_y_vec.d_data();
	float *input_ = this->input_.d_data();
	float *output_ = this->output_.d_data();
	float *reduce_output = this->reduce_output.d_data();
	int in_depth_ = this->in_depth_;
	int exp_y = this->exp_y;

	this->exp_y_vec.pop();
	this->exp_y_vec[this->exp_y] = 1;

	this->exp_y_vec.push();

	this->call_forward_output_layer(exp_y_vec, input_, reduce_output, output_, in_depth_, exp_y);

	this->reduce_output.pop();
	this->err = 0;
	for (int i = 0; i < in_depth_; i++) {
		this->err += this->reduce_output[i];
	}

}

void OutputLayer::back_prop() {
	this->g_.clear();

	float *exp_y_vec = this->exp_y_vec.d_data();
	float *input_ = this->input_.d_data();
	float *g_ = this->g_.d_data();
	int in_depth_ = this->in_depth_;

	this->call_backpropagation_output_layer(exp_y_vec, input_,
			g_, in_depth_);
}

void OutputLayer::init_weight() {
	this->reduce_output.resize(this->in_depth_);
	this->exp_y_vec.resize(this->in_depth_);
	this->g_.resize(this->in_depth_);
	this->input_.resize(this->in_depth_);
	this->output_.resize(this->in_depth_);
}

#else

void OutputLayer::forward() {
	this->err = 0;
	exp_y_vec.clear();
	exp_y_vec.resize(in_depth_);

	exp_y_vec[this->exp_y] = 1;
	for (size_t i = 0; i < in_depth_; i++) {
		err += 0.5 * (exp_y_vec[i] - input_[i]) * (exp_y_vec[i] - input_[i]);
	}
	output_ = input_;
}

void OutputLayer::init_weight() {
	this->g_.resize(this->in_depth_);

}

//FULL CPU BACKPROPAGATION
void OutputLayer::back_prop() {
	/* compute err terms of output layers */
	if (g_.size() != in_depth_) {
		g_.clear();
		g_.resize(in_depth_);
		printf("passou no if do bakc\n");
	}
	//printf("\ndebug back_prop output layer");
	for (size_t i = 0; i < in_depth_; i++) {
		g_[i] = ((exp_y_vec[i] - input_[i]) * df_sigmod(input_[i]));
	}
}

#endif

OutputLayer::OutputLayer(size_t in_depth) :
		Layer(1, 1, in_depth, 0, 0, 0, 0, 0) {
	this->init_weight();
	this->layer_type = "output";
}

/**
 * done
 * there is not outputlayer parameters
 */
void OutputLayer::save_layer(FILE *of) {
	this->save_base_layer(of);
}

void OutputLayer::load_layer(FILE *in) {
	this->load_base_layer(in);
}

void OutputLayer::back_prop_L1() {
	/* compute err terms of output layers
	 using L1 regularization */
	if (g_.size() != in_depth_) {
		g_.clear();
		g_.resize(in_depth_);
		printf("passou no if do back\n");
	}

#ifdef GPU
	this->g_.pop();
	this->input_.pop();
	this->exp_y_vec.pop();
#endif

	for (size_t i = 0; i < in_depth_; i++) {
		g_[i] = ((exp_y_vec[i] - input_[i]) * df_sigmod(input_[i])) // value error
		+ L1_LAMBDA * this->lenetWeightsSum; // L1 regularization
	}
#ifdef GPU
	this->g_.push();
#endif
}

void OutputLayer::back_prop_L2() {
	/* compute err terms of output layers
	 using L2 regularization */
	if (g_.size() != in_depth_) {
		g_.clear();
		g_.resize(in_depth_);
		printf("passou no if do back\n");
	}

#ifdef GPU
	this->g_.pop();
	this->input_.pop();
	this->exp_y_vec.pop();
#endif

	for (size_t i = 0; i < in_depth_; i++) {
		g_[i] = ((exp_y_vec[i] - input_[i]) * df_sigmod(input_[i])) // value error
		+ L2_LAMBDA * this->lenetSquaredWeightsSum; // L2 regularization
	}
#ifdef GPU
	this->g_.push();
#endif

}

void OutputLayer::set_sum_LeNet_weights(float_t sum_Lenet_weights) {
	this->lenetWeightsSum = 0.0;
	this->lenetWeightsSum = sum_Lenet_weights;
}

void OutputLayer::set_sum_LeNet_squared_weights(
		float_t sum_Lenet_squared_weights) {
	this->lenetSquaredWeightsSum = 0.0;
	this->lenetSquaredWeightsSum = sum_Lenet_squared_weights;
}
