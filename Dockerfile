ARG USE_FFMPEG=on
ARG USE_GSTREAMER=off
ARG USE_CUDA=off
ARG CUDA_ARCH=8.6
ARG USE_CUDNN=off

FROM ubuntu:latest

ARG USE_FFMPEG
ARG USE_GSTREAMER
ARG USE_CUDA
ARG CUDA_ARCH
ARG USE_CUDNN

RUN ["apt-get", "update"]
RUN ["apt-get", "upgrade", "-y"]

#Install dependencies
RUN ["apt-get", "install", "-y", "cmake", "g++", "git", "wget", "unzip", "pkg-config"]

RUN ["apt-get", "install", "-y", "ffmpeg", "libavcodec-dev", "libavformat-dev", "libavutil-dev", "libswscale-dev"]

#Download and setup OpenCV sources
WORKDIR /app/opencv-src

RUN ["wget", "-O", "opencv.zip", "https://github.com/opencv/opencv/archive/4.x.zip"]
RUN ["wget", "-O", "opencv_contrib.zip", "https://github.com/opencv/opencv_contrib/archive/4.x.zip"]

RUN ["unzip", "opencv.zip"]
RUN ["unzip", "opencv_contrib.zip"]

RUN ["rm", "opencv.zip"]
RUN ["rm", "opencv_contrib.zip"]

#Config OpenCV project
WORKDIR /app/opencv-src/opencv-4.x

COPY config_opencv.sh /app/opencv-src/config_opencv.sh

#RUN ["chmod", "u+x", "/app/opencv-src/config_opencv.sh"]
RUN /bin/bash /app/opencv-src/config_opencv.sh --ffmpeg=${USE_FFMPEG} --gstreamer=${USE_GSTREAMER} --cuda=${USE_CUDA} --cudnn=${USE_CUDNN} --cuda_arch=${CUDA_ARCH}

#Build OpenCV
RUN ["cmake", "--build", "build", "-j", "18"]
