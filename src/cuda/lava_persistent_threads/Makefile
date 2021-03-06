CC=g++
CUDAPATH=/usr/local/cuda
NVCC=$(CUDAPATH)/bin/nvcc
PRECISION?=single
LOGS?=1
USE_OMP?=1
BUILDPROFILER=0
FORJETSON=0


UPPERCASED_PRECISION=$(shell echo $(PRECISION) | tr a-z A-Z)
LOWERCASED_PRECISION=$(shell echo $(PRECISION) | tr A-Z a-z)

ARCH= 	-gencode arch=compute_35,code=[sm_35,compute_35]	# Tesla P100
#ARCH+= 	-gencode arch=compute_61,code=[sm_61,compute_61]	# Titan X | Titan Xp
ARCH+= 	-gencode arch=compute_62,code=[sm_62,compute_62]	# Tegra X2
#ARCH+= 	-gencode arch=compute_70,code=[sm_70,compute_70]	# Titan V | Tesla V100


NVCC_FLAGS= $(ARCH) -O3 -std=c++11 -L../common/lib
INCLUDE= -I$(CUDAPATH)/include -I../common -I$(CUDAPATH)/samples/common/inc/ -I../mxm_persistent_threads -I../common/include
LIBRARY= -L$(CUDAPATH)/lib64/
CXXFLAGS= -I$(CUDAPATH)/include -L$(CUDAPATH)/lib64/  -lcudart  -std=c++11 

TARGET=cuda_lava_persistent_threads_$(LOWERCASED_PRECISION)
RUN_SOURCES=./cuda_lava.cu

LOGHELPER_INC=../../include/
LOGHELPER_LIB=../../include/

ifeq ($(LOGS), 1)
INCLUDE+= -I$(LOGHELPER_INC)
NVCC_FLAGS+= -DLOGS -lLogHelper 
LIBRARY+= -L$(LOGHELPER_LIB) 
CXXFLAGS+= -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -DLOGS -lLogHelper 
endif

ifeq ($(USE_OMP), 1)
NVCC_FLAGS+= -DUSE_OMP -Xcompiler " -fopenmp -O3"
endif

ifeq ($(DEBUG), 1)
NVCC_FLAGS+= -g -G
endif

ifeq ($(BUILDPROFILER), 1)
	ifeq ($(FORJETSON), 1)
	NVCC_FLAGS += -DBUILDPROFILER -DFORJETSON=1 -lJTX2Inst -li2c
	else
	NVCC_FLAGS += -DBUILDPROFILER -L$(CUDAPATH)/lib64/stubs -lnvidia-ml  -lNVMLWrapper
	endif
endif 

NVCC_FLAGS+= -DPRECISION_$(UPPERCASED_PRECISION)

DATA_DIR=.
DEF_SIZE=4
NSTREAMS=100 #for persistent threads the size is NSTREAMS * DEF_SIZE
DEF_CHARGES_INPUT=$(DATA_DIR)/lava_charges_$(LOWERCASED_PRECISION)_$(DEF_SIZE)_$(NSTREAMS)
DEF_DISTANCES_INPUT=$(DATA_DIR)/lava_distances_$(LOWERCASED_PRECISION)_$(DEF_SIZE)_$(NSTREAMS)
DEF_GOLD=$(DATA_DIR)/lava_gold_$(LOWERCASED_PRECISION)_$(DEF_SIZE)_$(NSTREAMS)

all: $(TARGET)

$(TARGET): $(RUN_SOURCES)
	$(NVCC) $(INCLUDE) $(LIBRARY) $(NVCC_FLAGS) $(RUN_SOURCES) -o $(TARGET)

clean:
	rm -rf ./$(TARGET) $(DEF_CHARGES_INPUT) $(DEF_DISTANCES_INPUT) $(DEF_GOLD)

generate: $(TARGET)
	./$(TARGET) -boxes=$(DEF_SIZE) -generate -streams=$(NSTREAMS) -iterations=1 \
				-verbose -input_distances=$(DEF_DISTANCES_INPUT) \
				-input_charges=$(DEF_CHARGES_INPUT) -output_gold=$(DEF_GOLD)

test: $(RUN_EXEC) generate
	./$(TARGET) -boxes=$(DEF_SIZE) -streams=$(NSTREAMS) -iterations=10 \
				-verbose -input_distances=$(DEF_DISTANCES_INPUT) \
				-input_charges=$(DEF_CHARGES_INPUT) -output_gold=$(DEF_GOLD)
