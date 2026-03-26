#!/bin/bash


export DOLFINX_CMAKE_BUILD_TYPE="RelWithDebInfo"
#export EXTRA_LIB_HOME=$WORK/software
#export PETSC_DIR=$EXTRA_LIB_HOME/petsc-3.21.2-cuda
#export CONDA_PREFIX=$WORK/miniconda3/envs/fenics-cuda
#export LD_LIBRARY_PATH=$EXTRA_LIB_HOME/lib:$LD_LIBRARY_PATH
#export CMAKE_PREFIX_PATH=$EXTRA_LIB_HOME:$CMAKE_PREFIX_PATH
#module load intel/24.1
#module load impi phdf5
#export HDF5_DIR=/home1/apps/nvidia24/openmpi5/phdf5/1.14.4/cmake
export HDF5_DIR=$CONDA_PREFIX/cmake
export HDF5_VERSION=2.0.0
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
export CFLAGS=""
export PETSC_DIR=$CONDA_PREFIX
export PETSC_ARCH=""

basedir=$(pwd)

function build_hdf5() (
    [ -f hdf5_${HDF5_VERSION}.tar.gz ] || wget -nc https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_${HDF5_VERSION}.tar.gz && \
    tar xfz hdf5_${HDF5_VERSION}.tar.gz
    cd hdf5-hdf5_${HDF5_VERSION}
    cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX -DCMAKE_BUILD_TYPE=Release -DHDF5_ENABLE_PARALLEL=on -DHDF5_ENABLE_Z_LIB_SUPPORT=on -B build-dir 
    cmake --build build-dir -j 4 && \
    cmake --install build-dir 
    rm -rf build-dir
)

function build_cpp()
(
    [ -d dolfinx ] || git clone  https://github.com/FEniCS/dolfinx.git dolfinx
    cd dolfinx 
    mkdir -p build-real && \
    cd build-real && \
cmake -DMPI_C_COMPILER=$MPI_C_COMPILER -DMPI_CXX_COMPILER=$MPI_CXX_COMPILER -DDOLFINX_ENABLE_KAHIP=OFF -DDOLFINX_ENABLE_PARMETIS=OFF -DDOLFINX_ENABLE_ADIOS2=OFF -DOLFINX_ENABLE_SLEPC=OFF -DHDF5_DIR=$HDF5_DIR -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX -DCMAKE_BUILD_TYPE=${DOLFINX_CMAKE_BUILD_TYPE}  -DHDF5_ENABLE_PARALLEL=ON -DCMAKE_CXX_FLAGS=${DOLFINX_CMAKE_CXX_FLAGS} -DDOLFINX_SKIP_BUILD_TESTS=YES  -DDOLFINX_ENABLE_CUDATOOLKIT=ON ../cpp && \
make install -j4
    cd ..
    rm -rf build-real
)

function build_python()
{
export CMAKE_ARGS="-DMPI_C_COMPILER=$MPI_C_COMPILER -DMPI_CXX_COMPILER=$MPI_CXX_COMPILER -DHDF5_DIR=$HDF5_DIR -DHDF5_ENABLE_PARALLEL=ON"
export LDFLAGS=""
export CFLAGS=""
source $CONDA_PREFIX/lib/dolfinx/dolfinx.conf
cd $basedir/dolfinx/python && \
  pip install scikit-build-core && \
  python -m scikit_build_core.build requires | python -c "import sys, json; print(' '.join(json.load(sys.stdin)))" | xargs pip install && \
  pip -v install --check-build-dependencies --config-settings=build-dir="build" --config-settings=cmake.build-type="Debug"  --config-settings=install.strip=false --no-build-isolation -e .
}

set -e
#build_hdf5
build_cpp
build_python
