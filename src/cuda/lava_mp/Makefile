CXX=g++
CXXFLAGS= -std=c++11 -o3  -fPIC -pthread 
EXEC=cuda_lava

LOGS=1
BUILDPROFILER=0
OPERATIONNUM=194
PRECISION=single
DMR=none
DATA_DIR=../../../data/lava
DEF_SIZE=23
STREAMS=1
CHARGES_INPUT=$(DATA_DIR)/lava_$(PRECISION)_charges_$(DEF_SIZE)
DISTANCES_INPUT=$(DATA_DIR)/lava_$(PRECISION)_distances_$(DEF_SIZE)
GOLD=$(DATA_DIR)/lava_$(PRECISION)_gold_$(DEF_SIZE)
ITERATIONS=10
RELATIVEERROR=0


VPATH=./src
CUDAPATH=/usr/local/cuda
NVCC=$(CUDAPATH)/bin/nvcc
NVCCFLAGS= -std=c++11 -O3 -Xptxas -v

ARCH= -gencode arch=compute_35,code=[sm_35,compute_35] #Kepler
ARCH+= -gencode arch=compute_70,code=[sm_70,compute_70] #Titan V

INCLUDE= -I./src -I$(CUDAPATH)/include -I../../include -I../common

OBJDIR=./obj/
OBJ= setup_double.o  setup_float.o Parameters.o cuda_lava.o 

ifeq ($(DEBUG), 1) 
CXXFLAGS+=-O0 -g
NVCCFLAGS+= -g -G
endif

ifeq ($(RELATIVEERROR), 1)
NVCCFLAGS+= -DBUILDRELATIVEERROR=1
endif

ifeq ($(LOGS), 1)
CXXFLAGS+= -DLOGS
NVCCFLAGS+= -DLOGS
LDFLAGS+= -L../../include  -lLogHelper
endif

ifeq ($(BUILDPROFILER), 1)
CXXFLAGS+= -DBUILDPROFILER
LDFLAGS+= -L../common/lib -lNVMLWrapper -L$(CUDAPATH)/lib64/stubs -lnvidia-ml 
endif


LDFLAGS+= -L$(CUDAPATH)/lib64  -lcudart  -lcurand

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile


all: mkdir $(EXEC)


$(EXEC): $(OBJS)  
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS) $(INCLUDE)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(CXXFLAGS) -c $< -o $@ $(INCLUDE)
	
$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) -ccbin $(CXX) $(ARCH) $(NVCCFLAGS) -c $< -o $@ $(INCLUDE) 

mkdir:
	mkdir -p $(OBJDIR)

clean:
	rm -f $(OBJDIR)* $(EXEC)
	
generate:
	./$(EXEC) -boxes $(DEF_SIZE) -generate -streams $(STREAMS) \
				-iterations 1 -verbose \
				-input_distances $(DISTANCES_INPUT) \
				-input_charges $(CHARGES_INPUT)	\
				-output_gold $(GOLD) \
				-opnum $(OPERATIONNUM) -precision $(PRECISION) -redundancy $(DMR)

test:
	./$(EXEC) -boxes $(DEF_SIZE) -streams $(STREAMS) \
				-iterations $(ITERATIONS) -verbose \
				-input_distances $(DISTANCES_INPUT) \
				-input_charges $(CHARGES_INPUT) \
				-output_gold $(GOLD) \
				-opnum $(OPERATIONNUM) -precision $(PRECISION) -redundancy $(DMR)
				

test_no_dmr:
	./$(EXEC) -boxes $(DEF_SIZE) -streams $(STREAMS) \
				-iterations 10 -verbose \
				-input_distances $(DISTANCES_INPUT) \
				-input_charges $(CHARGES_INPUT) \
				-output_gold $(GOLD) \
				-opnum $(OPERATIONNUM) -precision $(PRECISION) -redundancy none
	
test_dmr_till_end:
	./$(EXEC) -boxes $(DEF_SIZE) -streams $(STREAMS) \
				-iterations 10 -verbose \
				-input_distances $(DISTANCES_INPUT) \
				-input_charges $(CHARGES_INPUT) \
				-output_gold $(GOLD) -opnum 44444\
				-opnum $(OPERATIONNUM) -precision $(PRECISION) -redundancy $(DMR)
