# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 2.8

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list

# Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/carol/heterogeneous_benchs/Hetero-Mark

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/carol/heterogeneous_benchs/Hetero-Mark

# Utility rule file for command_line_option_check.

# Include the progress variables for this target.
include src/common/command_line_option/CMakeFiles/command_line_option_check.dir/progress.make

src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/command_line_option.cc
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_parser_impl.cc
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_setting_help_printer.cc
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_setting_impl.cc
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/argument.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/argument_value.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/argument_value_factory.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/command_line_option.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_parser.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_parser_impl.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_setting.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_setting_help_printer.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_setting_impl.h
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_parser_impl_test.cc
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_setting_help_printer_test.cc
src/common/command_line_option/CMakeFiles/command_line_option_check: src/common/command_line_option/option_setting_impl_test.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/heterogeneous_benchs/Hetero-Mark/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold "Linting command_line_option_check"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/command_line_option && /usr/bin/cmake -E chdir /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/command_line_option clang-format -style=Google -i command_line_option.cc option_parser_impl.cc option_setting_help_printer.cc option_setting_impl.cc argument.h argument_value.h argument_value_factory.h command_line_option.h option_parser.h option_parser_impl.h option_setting.h option_setting_help_printer.h option_setting_impl.h option_parser_impl_test.cc option_setting_help_printer_test.cc option_setting_impl_test.cc
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/command_line_option && /usr/bin/cmake -E chdir /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/command_line_option cpplint.py command_line_option.cc option_parser_impl.cc option_setting_help_printer.cc option_setting_impl.cc argument.h argument_value.h argument_value_factory.h command_line_option.h option_parser.h option_parser_impl.h option_setting.h option_setting_help_printer.h option_setting_impl.h option_parser_impl_test.cc option_setting_help_printer_test.cc option_setting_impl_test.cc

command_line_option_check: src/common/command_line_option/CMakeFiles/command_line_option_check
command_line_option_check: src/common/command_line_option/CMakeFiles/command_line_option_check.dir/build.make
.PHONY : command_line_option_check

# Rule to build all files generated by this target.
src/common/command_line_option/CMakeFiles/command_line_option_check.dir/build: command_line_option_check
.PHONY : src/common/command_line_option/CMakeFiles/command_line_option_check.dir/build

src/common/command_line_option/CMakeFiles/command_line_option_check.dir/clean:
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/command_line_option && $(CMAKE_COMMAND) -P CMakeFiles/command_line_option_check.dir/cmake_clean.cmake
.PHONY : src/common/command_line_option/CMakeFiles/command_line_option_check.dir/clean

src/common/command_line_option/CMakeFiles/command_line_option_check.dir/depend:
	cd /home/carol/heterogeneous_benchs/Hetero-Mark && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/carol/heterogeneous_benchs/Hetero-Mark /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/command_line_option /home/carol/heterogeneous_benchs/Hetero-Mark /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/command_line_option /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/command_line_option/CMakeFiles/command_line_option_check.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/common/command_line_option/CMakeFiles/command_line_option_check.dir/depend

