export CGO_ENABLED=0
export GO111MODULE=on

.PHONY: build

ATOMIX_BENCHMARKS_VERSION := latest

all: build

build: # @HELP build the source code
build:
	GOOS=linux GOARCH=amd64 go build -o build/_output/k8s-benchmarks ./cmd/k8s-benchmarks

test: # @HELP run the unit tests and source code validation
test: build license_check linters
	go test github.com/atomix/k8s-benchmarks/...

linters: # @HELP examines Go source code and reports coding problems
	golangci-lint run

license_check: # @HELP examine and ensure license headers exist
	./build/licensing/boilerplate.py -v

proto: # @HELP build Protobuf/gRPC generated types
proto:
	docker run -it -v `pwd`:/go/src/github.com/atomix/k8s-benchmarks \
		-w /go/src/github.com/atomix/k8s-benchmarks \
		--entrypoint build/bin/compile_protos.sh \
		onosproject/protoc-go:stable

image: # @HELP build k8s-benchmarks Docker image
image: build
	docker build . -f build/docker/Dockerfile -t atomix/k8s-benchmarks:${ATOMIX_BENCHMARKS_VERSION}

push: # @HELP push k8s-benchmarks Docker image
	docker push atomix/k8s-benchmarks:${ATOMIX_BENCHMARKS_VERSION}
