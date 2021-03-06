/*
 * MicroReal.h
 *
 *  Created on: Mar 14, 2020
 *      Author: fernando
 */

#ifndef MICROREAL_H_
#define MICROREAL_H_

#include "Micro.h"
#include "Parameters.h"
#include "generic_log.h"

template<typename real_t>
struct MicroReal: public Micro<real_t> {

	MicroReal(Parameters& parameters, std::shared_ptr<rad::Log>& log) :
			Micro<real_t>(parameters, log) {
	}

	void execute_micro();
};

template<>
void MicroReal<float>::execute_micro();

#endif /* MICROREAL_H_ */
