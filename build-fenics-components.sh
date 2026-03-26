#!/bin/bash

DOLFINX_CMAKE_BUILD_TYPE="RelWithDebInfo"
#export EXTRA_LIB_HOME=$WORK/software
#export LD_LIBRARY_PATH=$EXTRA_LIB_HOME/lib:$LD_LIBRARY_PATH
#export CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:$EXTRA_LIB_HOME
export CC=gcc
export CXX=g++
set -e

#export mypip=/work/08009/bpachev/vista/miniconda3/envs/cuda-fenics-dev/bin/pip
function build_ufl() (
    [ -d ufl ] || git clone https://github.com/FEniCS/ufl
    cd ufl && pip install  .   
)
#export CMAKE_BIN_DIR=$(dirname $(which cmake))
function build_basix() (
    #pip install fenics-basix
    [ -d basix ] || git clone  https://github.com/FEniCS/basix basix
    cd basix
    cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX -DCMAKE_BUILD_TYPE=${DOLFINX_CMAKE_BUILD_TYPE} -DCMAKE_CXX_FLAGS=${DOLFINX_CMAKE_CXX_FLAGS} -B build-dir -S ./cpp && \
        cmake --build build-dir && \
        cmake --install build-dir -j 4 && \
        pip install  --check-build-dependencies ./python
    #rm -rf build-dir
)
function build_ffcx() (
    #pip install fenics-ffcx
    [ -d ffcx] || git clone  https://github.com/FEniCS/ffcx ffcx
    cd ffcx && pip install .
)

function build_backends() (
    [ -d ffcx-backends ] || git clone -b cuda-backend https://github.com/fenics-dolfiny/ffcx-backends ffcx-backends
    cd ffcx-backends
    pip install --check-build-dependencies .
)
#build_ufl
#build_basix
#build_ffcx
build_backends
