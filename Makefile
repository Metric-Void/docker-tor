TOR_VER = 0.4.7.13
ALPINE_VER=3.17

login:
	docker login

list-builders:
	docker buildx ls

initialise-builder:
	docker buildx create --name mybuilder
	docker buildx use mybuilder
	docker buildx inspect mybuilder --bootstrap

build:
	docker buildx build \
		--platform linux/amd64,linux/arm64,linux/arm/v7 \
		-t metricvoid/tor:$(TOR_VER) \
		-t metricvoid/tor:latest \
		--build-arg TOR_VER=$(TOR_VER) \
		--build-arg ALPINE_VER=$(ALPINE_VER) \
		--push \
		. \

build-docs:
	mkdocs build

CONTAINER_NAME:=multi-arch-test
run:
	docker run -i -d --rm \
		-p 9050:9050 \
		--name $(CONTAINER_NAME) \
		metricvoid/tor

ARM_SHA?=660432aec93b84c61d24541e5cf135491829df01ac900a20de325f8726f6118c
run-arm:
	docker run -i -d --rm \
		-p 9050:9050 \
		--name $(CONTAINER_NAME) \
		metricvoid/tor-socks@sha256:$(ARM_SHA)

stop:
	docker stop $(CONTAINER_NAME)

inspect:
	docker buildx imagetools inspect metricvoid/tor:latest

test-install-linux:
	curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 && chmod +x container-structure-test-linux-amd64 && mkdir -p $HOME/bin && export PATH=$PATH:$HOME/bin && mv container-structure-test-linux-amd64 $HOME/bin/container-structure-test

test-install-osx:
	curl -LO https://storage.googleapis.com/container-structure-test/latest/container-structure-test-darwin-amd64 && chmod +x container-structure-test-darwin-amd64 && sudo mv container-structure-test-darwin-amd64 /usr/local/bin/container-structure-test

test:
	container-structure-test test \
		--image tor:0.4.6.6 \
		--config unit-tests.yml
