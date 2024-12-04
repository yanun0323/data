.PHONY:

proto.install:
	sudo chmod -R 777 ./protoc &&\
	sudo rm -rf /usr/local/bin/protoc &&\
	sudo rm -rf /usr/local/include/google &&\
	sudo cp protoc/bin/protoc /usr/local/bin/protoc &&\
	sudo cp -r protoc/include/google /usr/local/include/google

bump-version:
	@if [ ! -f VERSION ]; then \
		echo "Error: VERSION file not found"; \
		exit 1; \
	fi
	@VERSION=$$(cat VERSION); \
	if ! echo "$$VERSION" | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$$" > /dev/null; then \
		echo "Error: Version format must be vX.X.X"; \
		exit 1; \
	fi
	@MAJOR=$$(echo "$$VERSION" | cut -d. -f1); \
	MINOR=$$(echo "$$VERSION" | cut -d. -f2); \
	PATCH=$$(echo "$$VERSION" | cut -d. -f3); \
	NEW_PATCH=$$((PATCH + 1)); \
	NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH"; \
	echo "$$NEW_VERSION"