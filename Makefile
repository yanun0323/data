.PHONY:

up:
	docker-compose up -d

down:
	docker-compose down

proto.install:
	sudo chmod -R 777 ./protoc &&\
	sudo rm -rf /usr/local/bin/protoc &&\
	sudo rm -rf /usr/local/include/google &&\
	sudo cp protoc/bin/protoc /usr/local/bin/protoc &&\
	sudo cp -r protoc/include/google /usr/local/include/google

release:
	@if [ ! -f VERSION ]; then \
		echo "Error: VERSION file not found"; \
	else \
		VERSION=$$(cat VERSION); \
	fi; \
	if [ -z "$$VERSION" ]; then \
		VERSION="v0.0.0"; \
	fi; \
	if ! echo "$$VERSION" | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$$" > /dev/null; then \
		echo "Error: Version format must be vX.X.X"; \
		exit 1; \
	else \
		MAJOR=$$(echo "$$VERSION" | cut -d. -f1) && \
		MINOR=$$(echo "$$VERSION" | cut -d. -f2) && \
		PATCH=$$(echo "$$VERSION" | cut -d. -f3) && \
		NEW_PATCH=$$((PATCH + 1)) && \
		NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH" && \
		rm -f ./VERSION &&\
		echo "$$NEW_VERSION" > ./VERSION &&\
		echo "add tag $$NEW_VERSION"; \
		git add . && \
		git commit -m "release version $$NEW_VERSION" && \
		git tag -a "$$NEW_VERSION" -m "version $$NEW_VERSION" && \
		git push &&\
		git push --tags && \
		echo "release version"; \
		echo ""; \
		echo "$$NEW_VERSION"; \
		echo ""; \
	fi

get.next.version:
	@if [ ! -f VERSION ]; then \
		echo "Error: VERSION file not found"; \
	else \
		VERSION=$$(cat VERSION); \
	fi; \
	if [ -z "$$VERSION" ]; then \
		VERSION="v0.0.0"; \
	fi; \
	if ! echo "$$VERSION" | grep -E "^v[0-9]+\.[0-9]+\.[0-9]+$$" > /dev/null; then \
		echo "Error: Version format must be vX.X.X"; \
		exit 1; \
	else \
		MAJOR=$$(echo "$$VERSION" | cut -d. -f1) && \
		MINOR=$$(echo "$$VERSION" | cut -d. -f2) && \
		PATCH=$$(echo "$$VERSION" | cut -d. -f3) && \
		NEW_PATCH=$$((PATCH + 1)) && \
		NEW_VERSION="$$MAJOR.$$MINOR.$$NEW_PATCH" && \
		echo "next version will be"; \
		echo ""; \
		echo "$$NEW_VERSION"; \
		echo ""; \
	fi
	
###############
#  migration  #
###############

migrate.env:
	@if [ ! -f Makefile.env ]; then \
		echo "MYSQL_SQL_PATH=./database/migration" > ./Makefile.env &&\
		echo "" >> ./Makefile.env &&\
		echo "DB_USER=root" >> ./Makefile.env &&\
		echo "DB_PASSWORD=root" >> ./Makefile.env &&\
		echo "DB_HOST=localhost" >> ./Makefile.env &&\
		echo "DB_PORT=3306" >> ./Makefile.env &&\
		echo "DB_NAME=database" >> ./Makefile.env; \
	fi

migrate.new:
	goose sqlite -dir=${MYSQL_SQL_PATH} . create . sql

migrate.validate:
	goose -dir=${MYSQL_SQL_PATH} validate

migrate.up:
	goose mysql "${DB_USER}:${DB_PASSWORD}@tcp(${DB_HOST}:${DB_PORT})/$(DB_NAME)?charset=utf8&parseTime=True&loc=Local" -dir=${MYSQL_SQL_PATH} up

migrate.down:
	goose mysql "${DB_USER}:${DB_PASSWORD}@tcp(${DB_HOST}:${DB_PORT})/$(DB_NAME)?charset=utf8&parseTime=True&loc=Local" -dir=${MYSQL_SQL_PATH} reset 