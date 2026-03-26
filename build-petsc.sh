
#!/bin/bash

# sript to build double precision PETSC with CUDA support

PETSC_VERSION=3.24.5
PETSC_SLEPC_OPTFLAGS="-O2"
PETSC_SRC_DIR=$(pwd)/petsc-$PETSC_VERSION-cuda
#module load cuda
#module load gcc/13.2.0
#module load openmpi/5.0.5
[ -d $PETSC_SRC_DIR ] || git clone -b v${PETSC_VERSION}  https://gitlab.com/petsc/petsc.git ${PETSC_SRC_DIR}  


install_deps () {
    NANOBIND_VERSION=1.8.0
    #NUMPY_VERSION=2.4.1
    pip3 install --no-cache-dir cffi mpi4py numba==0.63 numpy scikit-build-core[pyproject] && \
    pip3 install --no-cache-dir breathe clang-format cmakelang flake8 isort jupytext matplotlib mypy myst-parser nanobind==${NANOBIND_VERSION} pytest pytest-xdist ruff scipy sphinx sphinx_rtd_theme types-setuptools
}

install_petsc () {
#export I_MPI_ROOT=/scratch/projects/compilers/intel24.1/oneapi/mpi/2021.12
#export LD_LIBRARY_PATH=$I_MPI_ROOT/libfabric/lib:$I_MPI_ROOT/lib:$LD_LIBRARY_PATH
cd ${PETSC_SRC_DIR} && \
    # Real64, 32-bit int, CUDA
    ./configure \
    --prefix=$CONDA_PREFIX \
    --COPTFLAGS="${PETSC_SLEPC_OPTFLAGS}" \
    --CXXOPTFLAGS="${PETSC_SLEPC_OPTFLAGS}" \
    --FOPTFLAGS="${PETSC_SLEPC_OPTFLAGS}" \
    --with-64-bit-indices=no \
    --with-debugging=no \
    --with-fortran-bindings=no \
    --with-shared-libraries \
    --download-hypre \
    --download-metis \
    --download-mumps \
    --download-ptscotch \
    --download-scalapack \
    --donwload-spai \
    --download-fblaslapack=1 \
    --with-scalar-type=real \
    --with-cuda \
    --with-cudac=nvcc \
    --with-precision=double && 
#    --with-cuda-dir=/opt/apps/cuda/12.4/ \
#    --with-mpi-dir=$MPI_ROOT \
    make CUDAFLAGS=--std=c++17 ${MAKEFLAGS} all
    make install
}

install_petsc4py () {
    pip install --no-cache-dir  setuptools
    cd $PETSC_SRC_DIR/src/binding/petsc4py && \
    CFLAGS="" CXXFLAGS="" PETSC_DIR=$CONDA_PREFIX pip install --no-cache-dir -v .
}

set -e
install_petsc
export CFLAGS="-noswitcherror"
export CXXFLAGS="-noswitcherror"
install_deps
install_petsc4py
