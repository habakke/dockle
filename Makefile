BINARY          := dockle
ROOT_DIR        := $(if $(ROOT_DIR),$(ROOT_DIR),$(shell git rev-parse --show-toplevel))
BUILD_DIR       := $(ROOT_DIR)/dist
VERSION         := $(shell cat VERSION)
GITSHA          := $(shell git rev-parse --short HEAD)

.PHONY: build clean test fmt release-test release

prepare:
	mkdir -p $(BUILD_DIR)

test: prepare
	go test -short -coverprofile=$(BUILD_DIR)/cover.out ./...

build: prepare
	goreleaser build --snapshot --rm-dist --single-target

profile:
	go tool pprof -http=:7777 cpuprofile

clean:
	rm -rf $(BUILD_DIR)

fmt:
	go fmt ./...

release-test: export GITHUB_SHA=$(GITSHA)
release-test:
	goreleaser release --skip-publish --snapshot --rm-dist

release: export GITHUB_SHA=$(GITSHA)
release: release-test
	git tag -a $(VERSION) -m "Release" && git push origin $(VERSION)
