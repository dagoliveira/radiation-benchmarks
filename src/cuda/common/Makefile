SLEEP_TIME=1000 #in miliseconds

CXX=g++

MODE=cvr
CXXFLAGS= -shared
CUDAPATH=/usr/local/cuda
SRC=./src
JTX2SRC=$(SRC)/jtx2/src
LIB=./lib
CXXFLAGS+=-fPIC -Wall -Wextra -Wno-unknown-pragmas -std=c++11 -o3  -pthread -li2c

ifneq ($(SLEEP_TIME), 0)
CXXFLAGS+= -DSLEEP_TIME=$(SLEEP_TIME)
endif


LDFLAGS+= -L$(CUDAPATH)/lib64  -lcudart  -lcurand -L$(CUDAPATH)/lib64/stubs -lnvidia-ml 
INCLUDE= -I$(CUDAPATH)/include -I./include

JTX2OBJ= jtx1pow.o jtx1rate.o jtx1temp.o
OBJ= NVMLWrapper.o

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard ./include/*.h ./src/include/*.h) Makefile

LIBS= NVMLWrapper.so


all: clean $(OBJS) $(LIBS)


JTX2Inst.so: JTX2Inst.o $(JTX2OBJ) mklib
	ar $(MODE) -o $(LIB)/libJTX2Inst.so JTX2Inst.o $(JTX2OBJ)
	rm -f libJTX2Inst.o $(JTX2OBJ)

NVMLWrapper.so: NVMLWrapper.o mklib
	ar $(MODE) $(LIB)/libNVMLWrapper.so NVMLWrapper.o
	rm -f libNVMLWrapper.o

mklib:
	mkdir -p ./lib

%.o:  $(JTX2SRC)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@ $(LDFLAGS) $(INCLUDE)

%.o: $(SRC)/%.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@ $(LDFLAGS) $(INCLUDE)

clean:
	rm -rf $(LIBS) $(OBJ) lib/*.so
