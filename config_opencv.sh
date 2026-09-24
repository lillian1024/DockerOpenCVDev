#!/bin/sh

use_ffmpeg=false
use_cuda=false
use_cudnn=false
use_gstreamer=false

cuda_arch="8.6"

cudnn_include_dir="/usr/local/cuda/include"
cudnn_library_path="/usr/local/cuda/lib64/libcudnn.so"

for var in "$@"
do
    if [ "$var" = "--ffmpeg" ]; then
        use_ffmpeg=true
    elif [ "$var" = "--cuda" ]; then
        use_cuda=true
    elif [ "$var" = "--cudnn" ]; then
        use_cudnn=true
    elif [ "$var" = "--gstreamer" ]; then
        use_gstreamer=true
    else
        echo "Unrecognized argument"
        exit 2
    fi
done

cmake_args="-B build -D CMAKE_BUILD_TYPE=RELEASE -D BUILD_opencv_python3=ON"

if $use_ffmpeg; then
    cmake_args="$cmake_args -D WITH_FFMPEG=ON"
fi
if $use_cuda; then
    cmake_args="$cmake_args -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules -D WITH_CUDA=ON -D ENABLE_FAST_MATH=ON -D CUDA_FAST_MATH=ON -D WITH_CUBLAS=ON -D CUDA_ARCH_BIN=$cuda_arch "
fi
if $use_cudnn; then
    if ! $use_cuda; then
        echo "ERROR: CuDNN is used without CUDA which is not possible!"

        exit 1
    fi

    cmake_args="$cmake_args -D WITH_CUDNN=ON -D OPENCV_DNN_CUDA=ON -D CUDNN_INCLUDE_DIR='$cudnn_include_dir' -D CUDNN_LIBRARY='$cudnn_library_path'"
fi
if $use_gstreamer; then
    cmake_args="$cmake_args -D WITH_GSTREAMER=ON"
fi

#Config OpenCV
if ! cmake $cmake_args; then
    echo "Configuration failed!"

    exit 1
fi

#Check OpenCV's required modules
if $use_ffmpeg and ! grep -q '^#define HAVE_FFMPEG' build/cvconfig.h; then
    echo "ERROR: OpenCV was configured without FFmpeg support." >&2

    exit 1
fi

if $use_gstreamer and ! grep -q '^#define HAVE_GSTREAMER' build/cvconfig.h; then
    echo "ERROR: OpenCV was configured without GStreamer support." >&2

    exit 1
fi

echo "OpenCV configured successfully!"

exit 0
