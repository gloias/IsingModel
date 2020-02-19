

# define the shell to bash
SHELL := /bin/bash

# define the C/C++ compiler to use,default here is clang
CC = g++


NVCC = nvcc

EXECS = execV0 execV1 execV2 execV3

.PHONY: $(EXECS)

all: $(EXECS)

execV0: $(CC) src/ising-V0.c -o execV0 && ./execV0
execV1: $(NVCC) src/ising-V1.cu -o execV1 && ./execV1
execV2: $(NVCC) src/ising-V2.cu -o execV2 && ./execV2
execV3: $(NVCC) src/ising-V3.cu -o execV3 && ./execV3
