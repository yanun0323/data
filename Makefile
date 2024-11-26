.PHONY:

proto.install:
	sudo rm -rf /usr/local/bin/protoc &&\
	sudo rm -rf /usr/local/include/google &&\
	sudo cp protoc/bin/protoc /usr/local/bin/protoc &&\
	sudo cp -r protoc/include/google /usr/local/include/google