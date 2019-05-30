# makefile overrides to use Intel ICC compiler, double prec only.

CC=icc
FC=ifort

FFLAGS = -fPIC -O3 -xHost -debug all
CFLAGS= -std=c99
CFLAGS+= $(FFLAGS)

OMPFLAGS = -qopenmp

MFLAGS=-largeArrayDims -DMWF77_UNDERSCORE1 LDFLAGS='${LDFLAGS} -Wl,-rpath,${LD_LIBRARY_PATH}'
MEX_LIBS= -L${LD_LIBRARY_PATH} -lsvml -lifcore -limf -lintlc -lm 

ifneq ($(OMP),OFF)
CFLAGS += $(OMPFLAGS)
FFLAGS += $(OMPFLAGS)
endif

