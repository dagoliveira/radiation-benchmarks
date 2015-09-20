/*
 * Main.cpp
 *
 *  Created on: Sep 19, 2015
 *      Author: fernando
 */

#include "App.h"

int main(int argc, char** argv) {
	const char* keys =
			"{ h |  help    | false          | print help message }"
					"{ i |  input   |                | specify input image}"
					"{ c | camera   | -1             | enable camera capturing }"
					"{ v | video    |                | use video as input }"
					"{ g |  gray    | false          | convert image to gray one or not}"
					"{ s |  scale   | 1.0            | resize the image before detect}"
					"{ l |larger_win| false          | use 64x128 window}"
					"{ o |  output  |                | specify output path when input is images}";
	CommandLineParser cmd(argc, argv, keys);
	if (cmd.get<bool>("help")) {
		cout << "Usage : hog [options]" << endl;
		cout << "Available options:" << endl;
		cmd.printParams();
		return EXIT_SUCCESS;
	}

	App app(cmd);
	try {
		app.run();
	} catch (const Exception& e) {
		return cout << "error: " << e.what() << endl, 1;
	} catch (const exception& e) {
		return cout << "error: " << e.what() << endl, 1;
	} catch (...) {
		return cout << "unknown exception" << endl, 1;
	}
	return EXIT_SUCCESS;
}
