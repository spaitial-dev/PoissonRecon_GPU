cmake_minimum_required(VERSION 3.22)

set(CMAKE_CUDA_COMPILER "/usr/local/cuda/bin/nvcc")

# Must be set BEFORE project(... CUDA) — CMake 3.18+ auto-defaults this
# during the language enable step, so a `NOT DEFINED` guard placed after
# project() silently no-ops. Override via:
#   cmake .. -DCMAKE_CUDA_ARCHITECTURES="80-real"
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES OR CMAKE_CUDA_ARCHITECTURES STREQUAL "")
    set(CMAKE_CUDA_ARCHITECTURES 70-real 75-real 80-real 86-real 89-real 90-real 90-virtual
        CACHE STRING "CUDA archs (SASS for sm_70..sm_90 + PTX for >=9.0)" FORCE)
endif()

project(GPU_PoissonRecon LANGUAGES CXX CUDA)

#include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)

set(CMAKE_CUDA_STANDARD 14)

#set(CMAKE_CUDA_FLAGS "--expt-extended-lambda")

find_package(CUDA 11.7 REQUIRED)

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
