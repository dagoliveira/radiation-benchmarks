GPU?=1
DEBUG?=0
#for radiation setup
LOGS?=1
OMP?=1
BUILDPROFILER=0


SIZE?=8192
#6384 #8192 #4096 
ITERATIONS=10
INPUT=./input_$(SIZE)
GOLD=./gold_$(SIZE)
PENALTY=10



# This is what I use, uncomment if you know your arch and want to specify
ARCH= 	-gencode arch=compute_35,code=[sm_35,compute_35]		# Kepler
#ARCH+= 	-gencode arch=compute_61,code=[sm_61,compute_61]	# Titan X | Titan Xp
#ARCH+= 	-gencode arch=compute_62,code=[sm_62,compute_62]	# Tegra X2
ARCH+= 	-gencode arch=compute_70,code=[sm_70,compute_70]	# Titan V | Tesla V100
ARCH+= 	-gencode arch=compute_72,code=[sm_72,compute_72]	# Xavier


VPATH=./src/
TARGET=nw
OBJDIR=./obj/

CXX=g++
#g++
CUDAPATH=/usr/local/cuda
NVCC=$(CUDAPATH)/bin/nvcc 
OPTS=-O3
LDFLAGS= -lm -pthread -lstdc++ 
COMMON= 
CFLAGS=-Wall -Wfatal-errors  -Wunknown-pragmas -Wunused-function
RAD_DIR=/home/carol/radiation-benchmarks

INCLUDE=-I$(CUDAPATH)/include -I../common

ifeq ($(DEBUG), 1) 
OPTS=-O0 -g -DDEBUG
NVCCFLAGS+= -g -G -DDEBUG
endif

CFLAGS+=$(OPTS)
STDVERSION=--std=c++11

COMMON+= $(STDVERSION)

ifeq ($(GPU), 1) 
COMMON+= -DGPU -I$(CUDAPATH)/include/
CFLAGS+= -DGPU
LDFLAGS+= -L$(CUDAPATH)/lib64 -lcudart -lcurand
endif

ifeq ($(OMP), 1) 
CFLAGS+= -DOMP -fopenmp
endif


ifeq ($(BUILDPROFILER), 1)
CFLAGS+= -DBUILDPROFILER
LDFLAGS+= -L../common/lib -lNVMLWrapper -L$(CUDAPATH)/lib64/stubs -lnvidia-ml 
endif


OBJ= needle.o needle_kernel.o
#setup_tensor_cores.o

ifeq ($(LOGS), 1)
INCLUDE+=-I../../include/
NVCCFLAGS+= -DLOGS
CFLAGS+= -DLOGS
LDFLAGS+= -L../../include/ -lLogHelper -DLOGS=1
endif

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile

NVCCFLAGS+= -Xptxas -v

all: obj $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(COMMON) $(CFLAGS) $^ $(INCLUDE) -o $@  $(LDFLAGS)  

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(COMMON) $(CFLAGS) -c $< -o $@ $(INCLUDE) 

$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) -ccbin $(CXX) $(ARCH) $(COMMON) $(NVCCFLAGS) --compiler-options "$(CFLAGS)" $(INCLUDE) -c $< -o $@ 


obj:
	mkdir -p obj


.PHONY: clean
clean:
	rm -rf $(OBJS) $(TARGET)

generate:
	./$(TARGET) $(SIZE) $(PENALTY) $(INPUT) $(GOLD) $(ITERATIONS) 1

test:
	./$(TARGET) $(SIZE) $(PENALTY) $(INPUT) $(GOLD) $(ITERATIONS) 0
