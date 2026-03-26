#!/bin/bash
#conda install pip
conda install conda-forge::spdlog conda-forge::pugixml
#conda install -c conda-forge petsc=3.24.0=cuda12_real*
#conda install cmake
#conda install -c conda-forge compilers
# needed so all packages use the same MPI library
CC=mpicc MPICC=mpicc pip install --no-binary=mpi4py mpi4py
