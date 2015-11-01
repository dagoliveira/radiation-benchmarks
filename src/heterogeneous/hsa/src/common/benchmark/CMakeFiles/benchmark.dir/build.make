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

# Include any dependencies generated for this target.
include src/common/benchmark/CMakeFiles/benchmark.dir/depend.make

# Include the progress variables for this target.
include src/common/benchmark/CMakeFiles/benchmark.dir/progress.make

# Include the compile flags for this target's objects.
include src/common/benchmark/CMakeFiles/benchmark.dir/flags.make

src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o: src/common/benchmark/CMakeFiles/benchmark.dir/flags.make
src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o: src/common/benchmark/benchmark_runner.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/radiation-benchmarks/src/heterogeneous/hsa/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o"
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/benchmark.dir/benchmark_runner.cc.o -c /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark/benchmark_runner.cc

src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/benchmark.dir/benchmark_runner.cc.i"
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark/benchmark_runner.cc > CMakeFiles/benchmark.dir/benchmark_runner.cc.i

src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/benchmark.dir/benchmark_runner.cc.s"
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark/benchmark_runner.cc -o CMakeFiles/benchmark.dir/benchmark_runner.cc.s

src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o.requires:
.PHONY : src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o.requires

src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o.provides: src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o.requires
	$(MAKE) -f src/common/benchmark/CMakeFiles/benchmark.dir/build.make src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o.provides.build
.PHONY : src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o.provides

src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o.provides.build: src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o

# Object files for target benchmark
benchmark_OBJECTS = \
"CMakeFiles/benchmark.dir/benchmark_runner.cc.o"

# External object files for target benchmark
benchmark_EXTERNAL_OBJECTS =

src/common/benchmark/libbenchmark.a: src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o
src/common/benchmark/libbenchmark.a: src/common/benchmark/CMakeFiles/benchmark.dir/build.make
src/common/benchmark/libbenchmark.a: src/common/benchmark/CMakeFiles/benchmark.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX static library libbenchmark.a"
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark && $(CMAKE_COMMAND) -P CMakeFiles/benchmark.dir/cmake_clean_target.cmake
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/benchmark.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
src/common/benchmark/CMakeFiles/benchmark.dir/build: src/common/benchmark/libbenchmark.a
.PHONY : src/common/benchmark/CMakeFiles/benchmark.dir/build

src/common/benchmark/CMakeFiles/benchmark.dir/requires: src/common/benchmark/CMakeFiles/benchmark.dir/benchmark_runner.cc.o.requires
.PHONY : src/common/benchmark/CMakeFiles/benchmark.dir/requires

src/common/benchmark/CMakeFiles/benchmark.dir/clean:
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark && $(CMAKE_COMMAND) -P CMakeFiles/benchmark.dir/cmake_clean.cmake
.PHONY : src/common/benchmark/CMakeFiles/benchmark.dir/clean

src/common/benchmark/CMakeFiles/benchmark.dir/depend:
	cd /home/carol/radiation-benchmarks/src/heterogeneous/hsa && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/carol/radiation-benchmarks/src/heterogeneous/hsa /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark /home/carol/radiation-benchmarks/src/heterogeneous/hsa /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark /home/carol/radiation-benchmarks/src/heterogeneous/hsa/src/common/benchmark/CMakeFiles/benchmark.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/common/benchmark/CMakeFiles/benchmark.dir/depend

