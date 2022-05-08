PROJECT_NAME ?= cartographer-dsl

DOCKER_REPO?=hub.docker.com/thejokersthief/$(PROJECT_NAME)
PRJ_SRC_PATH:=github.com/TheJokersThief/$(PROJECT_NAME)
BIN_NAME?=$(PROJECT_NAME)
CGO_ENABLED?=0
GOOS?=darwin
GOARCH?=amd64
VERSION?=development
COMMIT_SHA?=$(shell git rev-parse --short HEAD)
BIN_PATH_LINUX:=dist/bin/linux/amd64
BIN_PATH_DARWIN_AMD64:=dist/bin/darwin/amd64
BIN_PATH_DARWIN_ARM64:=dist/bin/darwin/arm64
BIN_PATH_DARWIN:=dist/bin/darwin/$(GOARCH)

allPkgs = $(shell go list ./...)
allSrcDirs = cmd pkg

# Go environment setup (See: https://wiki.squarespace.net/display/GO/Go+Envars)
ifndef GOPATH
export GOPATH=$(shell go env "GOPATH")
endif

.PHONY: all
all: test static-analysis build archive

.PHONY: static-analysis
static-analysis: lint vet errcheck verify-gofmt

.PHONY: fmt
fmt:
	gofmt -s -w $(allSrcDirs)
	find . -name *.libsonnet -exec jsonnetfmt -i -n 4 {} \;
	find . -name *.jsonnet -exec jsonnetfmt -i -n 4 {} \;

.PHONY: verify-gofmt
verify-gofmt:
	./scripts/verify-gofmt.sh

.PHONY: tidy
tidy:
	go mod tidy

.PHONY: errcheck
errcheck:
	go run github.com/kisielk/errcheck -exclude errcheck-exclude.txt $(allPkgs)

.PHONY: vet
vet:
	go vet ./...

.PHONY: lint
lint:
	go run github.com/golangci/golangci-lint/cmd/golangci-lint run ./...

.PHONY: build
build: build-linux build-darwin

.PHONY: build-linux
build-linux:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=${CGO_ENABLED} go build --ldflags '-X ${PRJ_SRC_PATH}/cmd/${BIN_NAME}/main.VersionName=${VERSION} -X ${PRJ_SRC_PATH}/cmd/${BIN_NAME}/main.GitCommitSHA=${COMMIT_SHA}' -o ${BIN_PATH_LINUX}/${BIN_NAME} ./cmd/${BIN_NAME}

.PHONY: build-darwin
build-darwin: build-darwin-amd64 build-darwin-arm64

.PHONY: build-darwin-amd64
build-darwin-amd64:
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=${CGO_ENABLED} go build --ldflags '-X ${PRJ_SRC_PATH}/cmd/${BIN_NAME}/main.VersionName=${VERSION} -X ${PRJ_SRC_PATH}/cmd/${BIN_NAME}/main.GitCommitSHA=${COMMIT_SHA}' -o ${BIN_PATH_DARWIN_AMD64}/${BIN_NAME} ./cmd/${BIN_NAME}

.PHONY: build-darwin-arm64
build-darwin-arm64:
	GOOS=darwin GOARCH=arm64 CGO_ENABLED=${CGO_ENABLED} go build --ldflags '-X ${PRJ_SRC_PATH}/cmd/${BIN_NAME}/main.VersionName=${VERSION} -X ${PRJ_SRC_PATH}/cmd/${BIN_NAME}/main.GitCommitSHA=${COMMIT_SHA}' -o ${BIN_PATH_DARWIN_ARM64}/${BIN_NAME} ./cmd/${BIN_NAME}

.PHONY: install
install:
	GOOS=$(GOOS) GOARCH=$(GOARCH) CGO_ENABLED=${CGO_ENABLED} go install --ldflags '-X ${PRJ_SRC_PATH}/cmd/${BIN_NAME}/main.VersionName=${VERSION} -X ${PRJ_SRC_PATH}/cmd/${BIN_NAME}/main.GitCommitSHA=${COMMIT_SHA}' ./cmd/${BIN_NAME}

.PHONY: archive
archive: build
	mkdir -p dist/archive
	tar -c -z -v -C ${BIN_PATH_LINUX} -f dist/archive/${BIN_NAME}_${COMMIT_SHA}_Linux_x86_64.tar.gz ${BIN_NAME}
	tar -c -z -v -C ${BIN_PATH_DARWIN_AMD64} -f dist/archive/${BIN_NAME}_${COMMIT_SHA}_Darwin_x86_64.tar.gz ${BIN_NAME}
	tar -c -z -v -C ${BIN_PATH_DARWIN_ARM64} -f dist/archive/${BIN_NAME}_${COMMIT_SHA}_Darwin_arm64.tar.gz ${BIN_NAME}

.PHONY: test
test:
	go test -cover ./...

.PHONY: coverage
coverage:
	go test -coverprofile coverage.out ./...
	go tool cover -html=coverage.out
	rm coverage.out

.PHONY: clean
clean:
	rm -rf dist/
	go clean -testcache -modcache

.PHONY: container
container: build-linux
	docker build -t ${DOCKER_REPO}:${COMMIT_SHA} -f Dockerfile .
	docker tag ${DOCKER_REPO}:${COMMIT_SHA} ${DOCKER_REPO}:local

.PHONY: run
run:
	go run cmd/cartographer-dsl/main.go --file examples/test.jsonnet
