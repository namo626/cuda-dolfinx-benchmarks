#!/bin/bash

export DOLFINX_CMAKE_BUILD_TYPE="RelWithDebInfo"
# module purge
# module load gcc/14.2.0
# module load boost
# module load cuda
# module load openmpi/5.0.5
# module load cmake/3.29.5

export CC=gcc
export CXX=g++
export MPI_C_COMPILER=$(which mpicc)
export MPI_CXX_COMPILER=$(which mpicxx)
export HDF5_DIR=$CONDA_PREFIX/cmake
export PETSC_DIR=$CONDA_PREFIX
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
basedir=$(pwd)

function full_build()
(
export CFLAGS=""
[ -d cuda-dolfinx ] || git clone -b feature/ffcx-backends https://github.com/bpachev/cuda-dolfinx cuda-dolfinx
cd cuda-dolfinx && \
    mkdir -p build-real && \
    cd build-real && \
    cmake -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DMPI_C_COMPILER=$MPI_C_COMPILER -DMPI_CXX_COMPILER=$MPI_CXX_COMPILER -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX -DCMAKE_BUILD_TYPE=${DOLFINX_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS=${DOLFINX_CMAKE_CXX_FLAGS} -DCUDOLFINX_SKIP_BUILD_TESTS=YES -DHDF5_DIR=$HDF5_DIR -DHDF5_ENABLE_PARALLEL=ON ../cpp && \
make install -j4
)

function make_only()
(
  cd $basedir/cuda-dolfinx/build-real && make install
)

function build_python()
(
export CMAKE_ARGS="-DMPI_C_COMPILER=$MPI_C_COMPILER -DMPI_CXX_COMPILER=$MPI_CXX_COMPILER -DHDF5_DIR=$HDF5_DIR -DHDF5_ENABLE_PARALLEL=ON"
export LDFLAGS=""
source $CONDA_PREFIX/lib*/dolfinx/dolfinx.conf
source $CONDA_PREFIX/lib*/cudolfinx/cudolfinx.conf
cd cuda-dolfinx/python && \
  pip -v install --check-build-dependencies --config-settings=build-dir="build" --config-settings=cmake.build-type="Debug"  --config-settings=install.strip=false --no-build-isolation -e .
)

set -e
full_build
#make_only
build_python
