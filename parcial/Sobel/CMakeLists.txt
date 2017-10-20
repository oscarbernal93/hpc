#cmake -DCUDA_USE_STATIC_CUDA_RUNTIME=OFF .
cmake_minimum_required(VERSION 2.8)
project( Sobel )
find_package( OpenCV REQUIRED )
include_directories(${OpenCV_INCLUDE_DIRS})
find_package( CUDA REQUIRED )
set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS}; -O3; -arch=compute_52)
cuda_add_executable( global global.cu )
target_link_libraries( global ${OpenCV_LIBS} )
add_executable( secuencial secuencial.cpp )
target_link_libraries( secuencial ${OpenCV_LIBS} )
cuda_add_executable( compartida compartida.cu )
target_link_libraries( compartida ${OpenCV_LIBS} )
cuda_add_executable( constante constante.cu )
target_link_libraries( constante ${OpenCV_LIBS} )


