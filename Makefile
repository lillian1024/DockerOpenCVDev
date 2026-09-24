.PHONY: test all push

test:
	docker build -t opencv-test .

all:
	docker build -t lilian1024/opencv:4.14.0 .

push: all
	docker push lilian1024/opencv:4.14.0
