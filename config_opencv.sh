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

    arg="${arrARG[0]#"${arrARG[0]%%[![:space:]]*}"}"
    value="${arrARG[1]#"${arrARG[0]%%[![:space:]]*}"}"

    if [ "$arg" = "--ffmpeg" ]; then
        if [ "$value" = "on" ]; then
            use_ffmpeg=true
        elif [ "$value" != "off" ]; then
            echo "Unrecognized value: $value for ffmpeg argument expected: on/off!"
            exit 3
        fi
    elif [ "$arg" = "--cuda" ]; then
        if [ "$value" = "on" ]; then
            use_cuda=true
        elif [ "$value" != "off" ]; then
            echo "Unrecognized value: $value for cuda argument expected: on/off!"
            exit 3
        fi
    elif [ "$arg" = "--cudnn" ]; then
        if [ "$value" = "on" ]; then
            use_cudnn=true
        elif [ "$value" != "off" ]; then
            echo "Unrecognized value: $value for cudnn argument expected: on/off!"
            exit 3
        fi
    elif [ "$arg" = "--gstreamer" ]; then
        if [ "$value" = "on" ]; then
            use_gstreamer=true
        elif [ "$value" != "off" ]; then
            echo "Unrecognized value: $value for gstreamer argument expected: on/off!"
            exit 3
        fi
    elif [ "$arg" = "--cuda_arch" ]; then
        cuda_arch="$value"
    elif [ "$arg" = "--cudnn_include_dir" ]; then
        cudnn_include_dir="$value"
    elif [ "$arg" = "--cudnn_library_path" ]; then
        cudnn_library_path="$value"
    elif [ "$arg" = "--help" ]; then
        display_help

        exit 0
    else
        echo "Unrecognized argument: $arg!"

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

log_file=/tmp/config_logs.txt

#Config OpenCV
if ! cmake $cmake_args | tee $log_file; then
    echo "Configuration failed!"

    exit 1
fi

grep -Eq 'FFMPEG:[ \t]*YES' "$log_file"
has_ffmpeg=$?
grep -Eq 'CUDA:[ \t]*YES' "$log_file"
has_cuda=$?
grep -Eq 'CuDNN:[ \t]*YES' "$log_file"
has_cudnn=$?
grep -Eq 'GStreamer:[ \t]*YES' "$log_file"
has_gstreamer=$?

#Check OpenCV's required modules
if $use_ffmpeg && [ $has_ffmpeg -ne 0 ]; then
    echo "ERROR: OpenCV was configured without FFmpeg support." >&2

    exit 1
fi
if $use_cuda && [ $has_cuda -ne 0 ]; then
    echo "ERROR: OpenCV was configured without CUDA support." >&2

    exit 1
fi
if $use_cudnn && [ $has_cudnn -ne 0 ]; then
    echo "ERROR: OpenCV was configured without CuDNN support." >&2

    exit 1
fi
if $use_gstreamer && [ $has_gstreamer -ne 0 ]; then
    echo "ERROR: OpenCV was configured without GStreamer support." >&2

    exit 1
fi

rm $log_file

echo "OpenCV configured successfully!"

exit 0
