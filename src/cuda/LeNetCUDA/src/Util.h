/*
 * util.h
 *
 *  Created on: May 26, 2017
 *      Author: carol
 */

#ifndef UTIL_H_
#define UTIL_H_

#include <vector>
#include <cstdint>
#include <time.h>

#include <fstream>
#include <sstream>
#include <ostream>
#include <sys/time.h>

#include <exception>
#include <iostream>
#include <sstream>
#include <string>
#include <cstdlib>
#include <vector>
#include <math.h>
#include "boost/random.hpp"

#ifdef GPU
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

typedef thrust::host_vector<float_t> vec_t;
typedef thust::device_vector<float_t> vec_t_gpu;

#else

typedef std::vector<float_t> vec_t;

#endif

typedef std::vector<std::vector<float_t> > vec2d_t;

void inline error(std::string s){
	std::cout << "ERROR: " << s << std::endl;
	exit(-1);
}

struct Image {
	std::vector<std::vector<std::float_t> > img; // a image is represented by a 2-dimension vector
	size_t size; // width or height

	// construction
	Image(size_t size_, std::vector<std::vector<std::float_t> > img_);

	// display the image
	void display();

	// up size to 32, make up with 0
	void upto_32();

	std::vector<std::float_t> extend();
};

typedef Image* Img;

struct Sample {
	uint8_t label; // label for a specific digit
	std::vector<float_t> image;
	Sample(float_t label_, std::vector<float_t> image_);
};


int uniform_rand(int min, int max);

template<typename T>
T uniform_rand(T min, T max) {
	static boost::mt19937 gen(0);
	boost::uniform_real < T > dst(min, max);
	return dst(gen);
}

template<typename Iter>
void uniform_rand(Iter begin, Iter end, float_t min, float_t max) {
	for (Iter it = begin; it != end; ++it)
		*it = uniform_rand(min, max);
}

void disp_vec_t(vec_t v);

void disp_vec2d_t(vec2d_t v);

float_t dot(vec_t x, vec_t w);

float_t dot_per_batch(int batch, vec_t x, vec_t w);

//} // namespace convnet

//namespace jc {

std::string fileToString(const std::string& file_name);

unsigned int closestMultiple(unsigned int size, unsigned int divisor);

template<class T>
void showMatrix(T *matrix, unsigned int width, unsigned int height);

class Timer {
	timeval start_;
	timeval stop_;

public:

	void start();

	void stop();

	unsigned long getTime() const;

	friend std::ostream& operator<<(std::ostream& oss, const Timer& t) {
		unsigned long factors[] = { 60000000, 1000000, 1000 };
		const char *time_scales[] = { "m", "s", "ms" };

		unsigned long rr = t.getTime();
		for (int i = 0; i < 3; ++i) {
			oss << rr / factors[i] << time_scales[i] << " ";
			rr %= factors[i];
		}
		oss << rr << "us";

		return oss;
	}

};

//} //namespace jc

#endif /* UTIL_H_ */
