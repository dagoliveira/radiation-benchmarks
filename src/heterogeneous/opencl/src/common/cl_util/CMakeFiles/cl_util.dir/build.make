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
include src/common/cl_util/CMakeFiles/cl_util.dir/depend.make

# Include the progress variables for this target.
include src/common/cl_util/CMakeFiles/cl_util.dir/progress.make

# Include the compile flags for this target's objects.
include src/common/cl_util/CMakeFiles/cl_util.dir/flags.make

src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o: src/common/cl_util/CMakeFiles/cl_util.dir/flags.make
src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o: src/common/cl_util/cl_error.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/heterogeneous_benchs/Hetero-Mark/CMakeFiles $(CMAKE_PROGRESS_1)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/cl_util.dir/cl_error.cc.o -c /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_error.cc

src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/cl_util.dir/cl_error.cc.i"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_error.cc > CMakeFiles/cl_util.dir/cl_error.cc.i

src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/cl_util.dir/cl_error.cc.s"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_error.cc -o CMakeFiles/cl_util.dir/cl_error.cc.s

src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o.requires:
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o.requires

src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o.provides: src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o.requires
	$(MAKE) -f src/common/cl_util/CMakeFiles/cl_util.dir/build.make src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o.provides.build
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o.provides

src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o.provides.build: src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o

src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o: src/common/cl_util/CMakeFiles/cl_util.dir/flags.make
src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o: src/common/cl_util/cl_file.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/heterogeneous_benchs/Hetero-Mark/CMakeFiles $(CMAKE_PROGRESS_2)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/cl_util.dir/cl_file.cc.o -c /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_file.cc

src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/cl_util.dir/cl_file.cc.i"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_file.cc > CMakeFiles/cl_util.dir/cl_file.cc.i

src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/cl_util.dir/cl_file.cc.s"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_file.cc -o CMakeFiles/cl_util.dir/cl_file.cc.s

src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o.requires:
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o.requires

src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o.provides: src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o.requires
	$(MAKE) -f src/common/cl_util/CMakeFiles/cl_util.dir/build.make src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o.provides.build
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o.provides

src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o.provides.build: src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o

src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o: src/common/cl_util/CMakeFiles/cl_util.dir/flags.make
src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o: src/common/cl_util/cl_profiler.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/heterogeneous_benchs/Hetero-Mark/CMakeFiles $(CMAKE_PROGRESS_3)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/cl_util.dir/cl_profiler.cc.o -c /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_profiler.cc

src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/cl_util.dir/cl_profiler.cc.i"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_profiler.cc > CMakeFiles/cl_util.dir/cl_profiler.cc.i

src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/cl_util.dir/cl_profiler.cc.s"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_profiler.cc -o CMakeFiles/cl_util.dir/cl_profiler.cc.s

src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o.requires:
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o.requires

src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o.provides: src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o.requires
	$(MAKE) -f src/common/cl_util/CMakeFiles/cl_util.dir/build.make src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o.provides.build
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o.provides

src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o.provides.build: src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o

src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o: src/common/cl_util/CMakeFiles/cl_util.dir/flags.make
src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o: src/common/cl_util/cl_runtime.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/heterogeneous_benchs/Hetero-Mark/CMakeFiles $(CMAKE_PROGRESS_4)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/cl_util.dir/cl_runtime.cc.o -c /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_runtime.cc

src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/cl_util.dir/cl_runtime.cc.i"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_runtime.cc > CMakeFiles/cl_util.dir/cl_runtime.cc.i

src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/cl_util.dir/cl_runtime.cc.s"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_runtime.cc -o CMakeFiles/cl_util.dir/cl_runtime.cc.s

src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o.requires:
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o.requires

src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o.provides: src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o.requires
	$(MAKE) -f src/common/cl_util/CMakeFiles/cl_util.dir/build.make src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o.provides.build
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o.provides

src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o.provides.build: src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o

src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o: src/common/cl_util/CMakeFiles/cl_util.dir/flags.make
src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o: src/common/cl_util/cl_util.cc
	$(CMAKE_COMMAND) -E cmake_progress_report /home/carol/heterogeneous_benchs/Hetero-Mark/CMakeFiles $(CMAKE_PROGRESS_5)
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Building CXX object src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++   $(CXX_DEFINES) $(CXX_FLAGS) -o CMakeFiles/cl_util.dir/cl_util.cc.o -c /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_util.cc

src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/cl_util.dir/cl_util.cc.i"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -E /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_util.cc > CMakeFiles/cl_util.dir/cl_util.cc.i

src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/cl_util.dir/cl_util.cc.s"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && /usr/bin/c++  $(CXX_DEFINES) $(CXX_FLAGS) -S /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/cl_util.cc -o CMakeFiles/cl_util.dir/cl_util.cc.s

src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o.requires:
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o.requires

src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o.provides: src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o.requires
	$(MAKE) -f src/common/cl_util/CMakeFiles/cl_util.dir/build.make src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o.provides.build
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o.provides

src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o.provides.build: src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o

# Object files for target cl_util
cl_util_OBJECTS = \
"CMakeFiles/cl_util.dir/cl_error.cc.o" \
"CMakeFiles/cl_util.dir/cl_file.cc.o" \
"CMakeFiles/cl_util.dir/cl_profiler.cc.o" \
"CMakeFiles/cl_util.dir/cl_runtime.cc.o" \
"CMakeFiles/cl_util.dir/cl_util.cc.o"

# External object files for target cl_util
cl_util_EXTERNAL_OBJECTS =

src/common/cl_util/libcl_util.a: src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o
src/common/cl_util/libcl_util.a: src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o
src/common/cl_util/libcl_util.a: src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o
src/common/cl_util/libcl_util.a: src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o
src/common/cl_util/libcl_util.a: src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o
src/common/cl_util/libcl_util.a: src/common/cl_util/CMakeFiles/cl_util.dir/build.make
src/common/cl_util/libcl_util.a: src/common/cl_util/CMakeFiles/cl_util.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --red --bold "Linking CXX static library libcl_util.a"
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && $(CMAKE_COMMAND) -P CMakeFiles/cl_util.dir/cmake_clean_target.cmake
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/cl_util.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
src/common/cl_util/CMakeFiles/cl_util.dir/build: src/common/cl_util/libcl_util.a
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/build

src/common/cl_util/CMakeFiles/cl_util.dir/requires: src/common/cl_util/CMakeFiles/cl_util.dir/cl_error.cc.o.requires
src/common/cl_util/CMakeFiles/cl_util.dir/requires: src/common/cl_util/CMakeFiles/cl_util.dir/cl_file.cc.o.requires
src/common/cl_util/CMakeFiles/cl_util.dir/requires: src/common/cl_util/CMakeFiles/cl_util.dir/cl_profiler.cc.o.requires
src/common/cl_util/CMakeFiles/cl_util.dir/requires: src/common/cl_util/CMakeFiles/cl_util.dir/cl_runtime.cc.o.requires
src/common/cl_util/CMakeFiles/cl_util.dir/requires: src/common/cl_util/CMakeFiles/cl_util.dir/cl_util.cc.o.requires
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/requires

src/common/cl_util/CMakeFiles/cl_util.dir/clean:
	cd /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util && $(CMAKE_COMMAND) -P CMakeFiles/cl_util.dir/cmake_clean.cmake
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/clean

src/common/cl_util/CMakeFiles/cl_util.dir/depend:
	cd /home/carol/heterogeneous_benchs/Hetero-Mark && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/carol/heterogeneous_benchs/Hetero-Mark /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util /home/carol/heterogeneous_benchs/Hetero-Mark /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util /home/carol/heterogeneous_benchs/Hetero-Mark/src/common/cl_util/CMakeFiles/cl_util.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : src/common/cl_util/CMakeFiles/cl_util.dir/depend

