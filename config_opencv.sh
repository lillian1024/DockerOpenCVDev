#!/bin/sh

use_ffmpeg=false
use_cuda=false
use_cudnn=false
use_gstreamer=false

cuda_arch="8.6"

cudnn_include_dir="/usr/local/cuda/include"
cudnn_library_path="/usr/local/cuda/lib64/libcudnn.so"

display_help() {
    echo "Usage: script [arguments]"
    echo "Arguements:"
    echo -e "\t--help : display this help"
    echo -e "\t--ffmpeg=<state> : enable ffmpeg, state: on/off"
    echo -e "\t--cuda=<state> : enable cuda, state: on/off"
    echo -e "\t--cudnn=<state> : enable cudnn, state: on/off"
    echo -e "\t--gstreamer=<state> : enable gstreamer, state: on/off"

    echo -e "\t--cuda_arch=<arch_version> : specify the architecture version of cuda, arch_version example: 8.6"
    echo -e "\t--cudnn_include_dir=<path> : path to cudnn include directory"
    echo -e "\t--cudnn_library_path=<path> : path to cudnn library"
}

for var in "$@"
do
    arrARG=(${var//=/ })

    if [ "${arrARG[0]}" = "--ffmpeg" ]; then
        if [ "${arrARG[1]}" = "on" ]; then
            use_ffmpeg=true
        elif [ "${arrARG[1]}" != "off" ]; then
            echo "Unrecognized value for ffmpeg argument expected: on/off!"
            exit 3
        fi
    elif [ "${arrARG[0]}" = "--cuda" ]; then
        if [ "${arrARG[1]}" = "on" ]; then
            use_cuda=true
        elif [ "${arrARG[1]}" != "off" ]; then
            echo "Unrecognized value for cuda argument expected: on/off!"
            exit 3
        fi
    elif [ "${arrARG[0]}" = "--cudnn" ]; then
        if [ "${arrARG[1]}" = "on" ]; then
            use_cudnn=true
        elif [ "${arrARG[1]}" != "off" ]; then
            echo "Unrecognized value for cudnn argument expected: on/off!"
            exit 3
        fi
    elif [ "${arrARG[0]}" = "--gstreamer" ]; then
        if [ "${arrARG[1]}" = "on" ]; then
            use_gstreamer=true
        elif [ "${arrARG[1]}" != "off" ]; then
            echo "Unrecognized value for gstreamer argument expected: on/off!"
            exit 3
        fi
    elif [ "${arrARG[0]}" = "--cuda_arch" ]; then
        cuda_arch="${arrARG[1]}"
    elif [ "${arrARG[0]}" = "--cudnn_include_dir" ]; then
        cudnn_include_dir="${arrARG[1]}"
    elif [ "${arrARG[0]}" = "--cudnn_library_path" ]; then
        cudnn_library_path="${arrARG[1]}"
    elif [ "${arrARG[0]}" = "--help" ]; then
        display_help

        exit 0
    else
        echo "Unrecognized argument: ${arrARG[0]}!"

        display_help

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
if $use_cuda and ! grep -q '^#define HAVE_CUDA' build/cvconfig.h; then
    echo "ERROR: OpenCV was configured without CUDA support." >&2

    exit 1
fi
if $use_cudnn and ! grep -q '^#define HAVE_CUDNN' build/cvconfig.h; then
    echo "ERROR: OpenCV was configured without CuDNN support." >&2

    exit 1
fi
if $use_gstreamer and ! grep -q '^#define HAVE_GSTREAMER' build/cvconfig.h; then
    echo "ERROR: OpenCV was configured without GStreamer support." >&2

    exit 1
fi

echo "OpenCV configured successfully!"

exit 0
