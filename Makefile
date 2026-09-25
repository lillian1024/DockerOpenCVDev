.PHONY: test all push cuda

test:
	docker build -t opencv-test .

all:
	docker build -t lilian1024/opencv:4.x . --build-arg USE_FFMPEG=on

cuda:
	docker build -t lilian1024/opencv:4.x . --build-arg USE_FFMPEG=on --build-arg USE_CUDA=on --build-arg USE_CUDNN=on --build-arg BASE_IMAGE=nvidia/cuda:13.4.1-cudnn-devel-ubuntu26.04

push: all
	docker push lilian1024/opencv:4.x
