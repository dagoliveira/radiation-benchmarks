CXX=g++
NVCC=/usr/local/cuda/bin/nvcc
PRECISION?=float
DEF_SIZE?=16
LOGS?=1
USE_OMP?=1
SAFE_MALLOC?=0
DEF_INPUT?=/tmp/testmat
DEF_GOLD?=/tmp/goldtest
BLOCK_SIZE?=32

UPPERCASED_PRECISION=$(shell echo $(PRECISION) | tr a-z A-Z)
LOWERCASED_PRECISION=$(shell echo $(PRECISION) | tr A-Z a-z)

ifeq ($(UPPERCASED_PRECISION),HALF)
ARCH= 	-gencode arch=compute_60,code=[sm_60,compute_60]	# Tesla P100
ARCH+= 	-gencode arch=compute_61,code=[sm_61,compute_61]	# Titan X | Titan Xp
ARCH+= 	-gencode arch=compute_62,code=[sm_62,compute_62]	# Tegra X2
ARCH+= 	-gencode arch=compute_70,code=[sm_70,compute_70]	# Titan V | Tesla V100
else
#ARCH= 	-gencode arch=compute_35,code=[sm_35,compute_35]	# Tesla K40
ARCH+= 	-gencode arch=compute_53,code=[sm_53,compute_53]	# Tegra X1
ARCH+= 	-gencode arch=compute_60,code=[sm_60,compute_60]	# Tesla P100
ARCH+= 	-gencode arch=compute_61,code=[sm_61,compute_61]	# Titan X | Titan Xp
ARCH+= 	-gencode arch=compute_62,code=[sm_62,compute_62]	# Tegra X2
ARCH+= 	-gencode arch=compute_70,code=[sm_70,compute_70]	# Titan V | Tesla V100
endif

# Default vars
INCLUDE= -I/usr/local/cuda/include
LIBRARY= -L/usr/local/cuda/lib64/
CXXFLAGS= -I/usr/local/cuda/include -L/usr/local/cuda/lib64/ -lcudart  -std=c++11
LOGHELPER_INC=../../include/
LOGHELPER_LIB=../../include/
NVCCFLAGS+= $(ARCH) -std=c++11 -DBLOCK_SIZE=$(BLOCK_SIZE)

ifeq ($(LOGS), 1)
INCLUDE+= -I$(LOGHELPER_INC)
NVCCFLAGS+= -DLOGS -lLogHelper 
LIBRARY+= -L$(LOGHELPER_LIB) 
CXXFLAGS+= -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -DLOGS -lLogHelper 
endif

ifeq ($(USE_OMP), 1)
CXXFLAGS+= -DUSE_OMP -fopenmp
endif

ifeq ($(DEBUG), 1)
NVCCFLAGS+= -g -G
CXXFLAGS+= -g
endif

ifeq ($(SAFE_MALLOC), 1)
NVCCFLAGS+= -I../../include/safe_memory -DSAFE_MALLOC -lSafeMemory 
LIBRARY+= -L../../include/safe_memory
endif

ifeq ($(LOGS), 1)
INCLUDE+= -I$(LOGHELPER_INC)
LIBRARY+= -L$(LOGHELPER_LIB) 
CXXFLAGS+= -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -DLOGS -lLogHelper 
endif

OBJDIR=./obj/
OBJ= cuda_lud.o
OBJS = $(addprefix $(OBJDIR), $(OBJ))
EXEC=$(PRECISION)_trip_lud

all: clean mkdir $(EXEC)

$(EXEC): $(OBJS) 
	$(CXX)  $^ -o $@ $(LDFLAGS) $(CXXFLAGS)

$(OBJDIR)%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(OBJDIR)%.o: %.cu 
	$(NVCC) $(ARCH) $(NVCCFLAGS) --compiler-options "$(CXXFLAGS)" -c $< -o $@

generate: 
	./$(EXEC) -size=$(DEF_SIZE) -generate -input=$(DEF_INPUT) -gold=$(DEF_GOLD) -precision=$(PRECISION)

test: $(EXEC) generate
	./$(EXEC) -size=$(DEF_SIZE) -input=$(DEF_INPUT) -gold=$(DEF_GOLD) -iterations=10 -verbose -precision=$(PRECISION)
	
mkdir:
	mkdir -p ./obj

clean:
	rm -rf $(EXEC) ./obj/*


