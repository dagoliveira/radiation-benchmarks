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

# Include any dependencies generated for this target.
include src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/depend.make

# Include the progress variables for this target.
include src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/progress.make

# Include the compile flags for this target's objects.
include src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/flags.make

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/flags.make
src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o: src/opencl20/fir_cl20/fir_cl20.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/heterogeneous_benchs/Hetero-Mark/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/fir_cl20.dir/fir_cl20.cc.o -c /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/fir_cl20.cc

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/fir_cl20.dir/fir_cl20.cc.i"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/fir_cl20.cc > CMakeFiles/fir_cl20.dir/fir_cl20.cc.i

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/fir_cl20.dir/fir_cl20.cc.s"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/fir_cl20.cc -o CMakeFiles/fir_cl20.dir/fir_cl20.cc.s

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o.requires:
.PHONY : src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o.requires

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o.provides: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o.requires
	$(MAKE) -f src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/build.make src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o.provides.build
.PHONY : src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o.provides

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o.provides.build: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/flags.make
src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o: src/opencl20/fir_cl20/main.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/heterogeneous_benchs/Hetero-Mark/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/fir_cl20.dir/main.cc.o -c /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/main.cc

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/fir_cl20.dir/main.cc.i"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/main.cc > CMakeFiles/fir_cl20.dir/main.cc.i

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/fir_cl20.dir/main.cc.s"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/main.cc -o CMakeFiles/fir_cl20.dir/main.cc.s

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o.requires:
.PHONY : src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o.requires

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o.provides: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o.requires
	$(MAKE) -f src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/build.make src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o.provides.build
.PHONY : src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o.provides

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o.provides.build: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o

# Object files for target fir_cl20
fir_cl20_OBJECTS = \
"CMakeFiles/fir_cl20.dir/fir_cl20.cc.o" \
"CMakeFiles/fir_cl20.dir/main.cc.o"

# External object files for target fir_cl20
fir_cl20_EXTERNAL_OBJECTS =

src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/build.make
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/common/cl_util/libcl_util.a
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/common/time_measurement/libtime_measurement.a
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/common/command_line_option/libcommand_line_option.a
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/common/benchmark/libbenchmark.a
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/logHelper/liblogHelper.a
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: /usr/lib/x86_64/libOpenCL.so
src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX executable bin/x86_64/Release/fir_cl20"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/fir_cl20.dir/link.txt --verbose=$(VERBOSE)
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/cmake -E copy_if_different /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/fir_cl20_kernel.cl /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/bin/x86_64/Release/.
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/cmake -E copy_if_different /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/fir_cl20_kernel.cl ./
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/cmake -E copy_if_different /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/input/temp.dat /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/bin/x86_64/Release/.
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && /usr/bin/cmake -E copy_if_different /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/input/temp.dat ./

# Rule to build all files generated by this target.
src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/build: src/opencl20/fir_cl20/bin/x86_64/Release/fir_cl20
.PHONY : src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/build

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/requires: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/fir_cl20.cc.o.requires
src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/requires: src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/main.cc.o.requires
.PHONY : src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/requires

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/clean:
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 && $(CMAKE_COMMAND) -P CMakeFiles/fir_cl20.dir/cmake_clean.cmake
.PHONY : src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/clean

src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/depend:
	cd /home/carol/heterogeneous_benchs/Hetero-Mark && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/carol/heterogeneous_benchs/Hetero-Mark /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 /home/carol/heterogeneous_benchs/Hetero-Mark /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20 /home/carol/heterogeneous_benchs/Hetero-Mark/src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/opencl20/fir_cl20/CMakeFiles/fir_cl20.dir/depend

