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
CMAKE_SOURCE_DIR = /home/carol/radiation-benchmarks/src/heterogeneous/hsa

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/carol/radiation-benchmarks/src/heterogeneous/hsa

# Utility rule file for fir_hsa_check.

# Include the progress variables for this target.
include src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/progress.make

src/hsa/fir_hsa/CMakeFiles/fir_hsa_check: src/hsa/fir_hsa/main.cc
src/hsa/fir_hsa/CMakeFiles/fir_hsa_check: src/hsa/fir_hsa/fir_benchmark.h
src/hsa/fir_hsa/CMakeFiles/fir_hsa_check: src/hsa/fir_hsa/fir_benchmark.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/radiation-benchmarks/src/heterogeneous/hsa/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold "Linting fir_hsa_check"
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/hsa/fir_hsa && /usr/bin/cmake -E chdir /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/hsa/fir_hsa cpplint.py main.cc fir_benchmark.h fir_benchmark.cc

fir_hsa_check: src/hsa/fir_hsa/CMakeFiles/fir_hsa_check
fir_hsa_check: src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/build.make
.PHONY : fir_hsa_check

# Rule to build all files generated by this target.
src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/build: fir_hsa_check
.PHONY : src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/build

src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/clean:
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/hsa/fir_hsa && $(CMAKE_COMMAND) -P CMakeFiles/fir_hsa_check.dir/cmake_clean.cmake
.PHONY : src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/clean

src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/depend:
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/carol/radiation-benchmarks/src/heterogeneous/hsa /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/hsa/fir_hsa /home/carol/radiation-benchmarks/src/heterogeneous/hsa /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/hsa/fir_hsa /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/hsa/fir_hsa/CMakeFiles/fir_hsa_check.dir/depend

