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
CMAKE_SOURCE_DIR = /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl

# Include any dependencies generated for this target.
include src/common/time_measurement/CMakeFiles/time_measurement.dir/depend.make

# Include the progress variables for this target.
include src/common/time_measurement/CMakeFiles/time_measurement.dir/progress.make

# Include the compile flags for this target's objects.
include src/common/time_measurement/CMakeFiles/time_measurement.dir/flags.make

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o: src/common/time_measurement/CMakeFiles/time_measurement.dir/flags.make
src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o: src/common/time_measurement/time_keeper_impl.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o -c /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_keeper_impl.cc

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/time_measurement.dir/time_keeper_impl.cc.i"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_keeper_impl.cc > CMakeFiles/time_measurement.dir/time_keeper_impl.cc.i

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/time_measurement.dir/time_keeper_impl.cc.s"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_keeper_impl.cc -o CMakeFiles/time_measurement.dir/time_keeper_impl.cc.s

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o.requires:
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o.requires

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o.provides: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o.requires
	$(MAKE) -f src/common/time_measurement/CMakeFiles/time_measurement.dir/build.make src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o.provides.build
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o.provides

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o.provides.build: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o: src/common/time_measurement/CMakeFiles/time_measurement.dir/flags.make
src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o: src/common/time_measurement/time_keeper_summary_printer.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o -c /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_keeper_summary_printer.cc

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.i"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_keeper_summary_printer.cc > CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.i

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.s"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_keeper_summary_printer.cc -o CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.s

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o.requires:
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o.requires

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o.provides: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o.requires
	$(MAKE) -f src/common/time_measurement/CMakeFiles/time_measurement.dir/build.make src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o.provides.build
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o.provides

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o.provides.build: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o: src/common/time_measurement/CMakeFiles/time_measurement.dir/flags.make
src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o: src/common/time_measurement/time_measurement_impl.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o -c /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_measurement_impl.cc

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/time_measurement.dir/time_measurement_impl.cc.i"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_measurement_impl.cc > CMakeFiles/time_measurement.dir/time_measurement_impl.cc.i

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/time_measurement.dir/time_measurement_impl.cc.s"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/time_measurement_impl.cc -o CMakeFiles/time_measurement.dir/time_measurement_impl.cc.s

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o.requires:
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o.requires

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o.provides: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o.requires
	$(MAKE) -f src/common/time_measurement/CMakeFiles/time_measurement.dir/build.make src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o.provides.build
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o.provides

src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o.provides.build: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o

src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o: src/common/time_measurement/CMakeFiles/time_measurement.dir/flags.make
src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o: src/common/time_measurement/timer_impl.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/CMakeFiles $(CMAKE_PROGRESS_4)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/time_measurement.dir/timer_impl.cc.o -c /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/timer_impl.cc

src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/time_measurement.dir/timer_impl.cc.i"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/timer_impl.cc > CMakeFiles/time_measurement.dir/timer_impl.cc.i

src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/time_measurement.dir/timer_impl.cc.s"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/timer_impl.cc -o CMakeFiles/time_measurement.dir/timer_impl.cc.s

src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o.requires:
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o.requires

src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o.provides: src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o.requires
	$(MAKE) -f src/common/time_measurement/CMakeFiles/time_measurement.dir/build.make src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o.provides.build
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o.provides

src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o.provides.build: src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o

# Object files for target time_measurement
time_measurement_OBJECTS = \
"CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o" \
"CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o" \
"CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o" \
"CMakeFiles/time_measurement.dir/timer_impl.cc.o"

# External object files for target time_measurement
time_measurement_EXTERNAL_OBJECTS =

src/common/time_measurement/libtime_measurement.a: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o
src/common/time_measurement/libtime_measurement.a: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o
src/common/time_measurement/libtime_measurement.a: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o
src/common/time_measurement/libtime_measurement.a: src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o
src/common/time_measurement/libtime_measurement.a: src/common/time_measurement/CMakeFiles/time_measurement.dir/build.make
src/common/time_measurement/libtime_measurement.a: src/common/time_measurement/CMakeFiles/time_measurement.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX static library libtime_measurement.a"
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && $(CMAKE_COMMAND) -P CMakeFiles/time_measurement.dir/cmake_clean_target.cmake
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/time_measurement.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
src/common/time_measurement/CMakeFiles/time_measurement.dir/build: src/common/time_measurement/libtime_measurement.a
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/build

src/common/time_measurement/CMakeFiles/time_measurement.dir/requires: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_impl.cc.o.requires
src/common/time_measurement/CMakeFiles/time_measurement.dir/requires: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_keeper_summary_printer.cc.o.requires
src/common/time_measurement/CMakeFiles/time_measurement.dir/requires: src/common/time_measurement/CMakeFiles/time_measurement.dir/time_measurement_impl.cc.o.requires
src/common/time_measurement/CMakeFiles/time_measurement.dir/requires: src/common/time_measurement/CMakeFiles/time_measurement.dir/timer_impl.cc.o.requires
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/requires

src/common/time_measurement/CMakeFiles/time_measurement.dir/clean:
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement && $(CMAKE_COMMAND) -P CMakeFiles/time_measurement.dir/cmake_clean.cmake
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/clean

src/common/time_measurement/CMakeFiles/time_measurement.dir/depend:
	cd /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement /home/carol/vinicius/radiation-benchmarks/src/heterogeneous/opencl/src/common/time_measurement/CMakeFiles/time_measurement.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/common/time_measurement/CMakeFiles/time_measurement.dir/depend

