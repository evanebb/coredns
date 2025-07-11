GITCOMMIT?=$(shell git describe --dirty --always)

build:
	CGO_ENABLED=0 go build -ldflags="-s -w -X github.com/coredns/coredns/coremain.GitCommit=$(GITCOMMIT)" -o ./bin/coredns
