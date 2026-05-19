cmake_minimum_required(VERSION 3.22)

set(CMAKE_CUDA_COMPILER "/usr/local/cuda/bin/nvcc")

project(GPU_PoissonRecon LANGUAGES CXX CUDA)

#include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)

set(CMAKE_CUDA_STANDARD 14)

#set(CMAKE_CUDA_FLAGS "--expt-extended-lambda")

find_package(CUDA 11.7 REQUIRED)

# Compile SASS for every modern NVIDIA arch we ship on (T4 sm_75 .. H100 sm_90)
# plus a PTX-only entry for sm_90 so the driver can JIT for any future arch
# >= 9.0. The previous hardcoded `-arch=sm_80` produced a binary that only ran
# on Ampere A100, and silently crashed with thrust system_errors (mapped to
# cudaErrorInvalidDevice / "no kernel image" on every other GPU.
# Override at configure time with e.g. -DCMAKE_CUDA_ARCHITECTURES="80-real".
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 70-real 75-real 80-real 86-real 89-real 90-real 90-virtual)
endif()

add_executable(GPU_PoissonRecon main.cu
        CmdLineParser.cuh CmdLineParser.inl CmdLineParser.cu
        Geometry.cuh Geometry.inl Geometry.cu
        plyfile.cu PlyFile.cuh PointStream.cuh PointStream.inl
        Debug.cuh OctNode.cuh Hash.cuh
        BinaryNode.cuh
        Factor.cu Factor.cuh
        Polynomial.cuh Polynomial.inl
        PPolynomial.cuh PPolynomial.inl
        FunctionData.cuh FunctionData.inl
        ConfirmedPPolynomial.cuh
        Allocator.cuh Vector.cuh Vector.inl
        SparseMatrix.cuh SparseMatrix.inl
        ConfirmedSparseMatrix.cuh ConfirmedVector.cuh
        CG_CUDA.cuh exception.h
        helper_cuda.h helper_image.h helper_timer.h helper_string.h helper_functions.h MarchingCubes.cuh)

set_target_properties(GPU_PoissonRecon PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON
        CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")

target_link_libraries( GPU_PoissonRecon ${CUDA_cusparse_LIBRARY} ${CUDA_cusolver_LIBRARY} ${CUDA_cublas_LIBRARY})

message(STATUS "GPU_PoissonRecon CUDA Architectures: ${CMAKE_CUDA_ARCHITECTURES}")
