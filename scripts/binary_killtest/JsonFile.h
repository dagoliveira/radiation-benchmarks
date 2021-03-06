/*
 * JsonFile.h
 *
 *  Created on: 19/01/2019
 *      Author: fernando
 */

#ifndef JSONFILE_H_
#define JSONFILE_H_
#include <string>
#include <vector>

namespace radiation {

#define JSON_ENTRIES 2 //Size of Json entries on Json file

//!  JsonFile class.
/*!
 This class is to parse json files generated by
 the test applications
 It is not suppose to be able to edit json file from this class
 for that uses each benchmark configure.py instead
 */
class JsonFile {
private:
	//! All lines inside a json file.
	/*! All lines that will be executed in a given json file
	 */
	std::vector<std::pair<std::string, std::string> > all_json_lines;

public:

	//! JsonFile constructor.
	/*!
	 JsonFile constructor, it will create a object that contains the data
	 extracted from file_path parameter

	 \param std::string file_path is the path to the json file
	 */
	JsonFile(std::string file_path);

	/*!
	 * << Operator
	 \return Ostream
	 */
	friend std::ostream& operator<<(std::ostream& stream, const JsonFile& jf);

	//! Get all command lines
	/*!
	 * Get all command lines present in json file
	 * Each pair contains
	 * first: kill command
	 * second: command line
	 \return the begin and the end iterator for the all lines vector
	 */
	std::vector<std::pair<std::string, std::string> > get_all_command_lines();

};

} /* namespace radiation */

#endif /* JSONFILE_H_ */
