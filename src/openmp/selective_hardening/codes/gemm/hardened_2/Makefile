# C compiler
CC = gcc
DEFAULT_INPUT=8192

EXEC=gemm

NAME_SUFFIX=_hardened_2

#default is float
CC_FLAGS = -std=c99 -O0 -DDEFAULT_INPUT_SIZE=$(DEFAULT_INPUT) -DPRECISION=32 -fopenmp -DBOFFSET=12

SOURCES_CHECK = gemm.c /home/carol/radiation-benchmarks/src/openmp/selective_hardening/src/selective_hardening.c

INCLUDE+= -I/home/carol/radiation-benchmarks/src/include
LIBRARY+= -L/home/carol/radiation-benchmarks/src/include -lLogHelper -DLOGS

all: $(EXEC)_gen $(EXEC)_check $(EXEC)_err_inj $(EXEC)_timing 

$(EXEC)_gen: gemm_gen.c 
	$(CC) $(CC_FLAGS)  gemm_gen.c -o $(EXEC)_gen $(INCLUDE) $(LIBRARY) 

$(EXEC)_check: gemm.c 
	$(CC) $(CC_FLAGS) $(SOURCES_CHECK) -o $(EXEC)_check$(NAME_SUFFIX) $(INCLUDE) $(LIBRARY)

$(EXEC)_err_inj: gemm.c  
	$(CC) $(CC_FLAGS) $(SOURCES_CHECK) -DERR_INJ -o $(EXEC)_err_inj$(NAME_SUFFIX) $(INCLUDE) $(LIBRARY)

$(EXEC)_timing: gemm.c
	$(CC) $(CC_FLAGS) $(SOURCES_CHECK) -DTIMING -o $(EXEC)_timing$(NAME_SUFFIX) $(INCLUDE) $(LIBRARY)

generate:
	./$(EXEC)_gen 4 1024 8 /tmp/testa /tmp/testb /tmp/gold

test:
	./$(EXEC)_check 4 1024 8 /tmp/testa /tmp/testb /tmp/gold 10

clean:
	rm -f gemm_gen gemm_check$(NAME_SUFFIX) gemm_err_inj$(NAME_SUFFIX) gemm_timing$(NAME_SUFFIX)
