FROM ubuntu:latest

RUN ["apt", "update"]
RUN ["apt", "upgrade", "-y"]

#Install dependencies
RUN ["apt", "install", "-y", "cmake", "g++", "git", "wget", "unzip"]

RUN ["apt", "install", "-y", "ffmpeg", "libavcodec-dev", "libavformat-dev", "libavutil-dev", "libswscale-dev"]

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
RUN ["/bin/sh", "/app/opencv-src/config_opencv.sh", "--ffmpeg"]

#Build OpenCV
RUN ["cmake", "--build", "build", "-j", "18"]
