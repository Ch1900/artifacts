PACKAGE := github.com/meatballhat/artifacts
SUBPACKAGES := $(PACKAGE)/path $(PACKAGE)/upload $(PACKAGE)/env $(PACKAGE)/upload

VERSION_VAR := main.VersionString
REPO_VERSION := $(shell git describe --always --dirty --tags)

REV_VAR := main.RevisionString
REPO_REV := $(shell git rev-parse --sq HEAD)

GO ?= go
GOX ?= gox
GODEP ?= godep
GOBUILD_LDFLAGS := -ldflags "-X $(VERSION_VAR) $(REPO_VERSION) -X $(REV_VAR) $(REPO_REV)"
GOBUILD_FLAGS ?=
GOX_FLAGS ?= -output="build/{{.OS}}/{{.Arch}}/{{.Dir}}" -os="linux darwin windows"

.PHONY: all
all: clean test save USAGE.txt UPLOAD_USAGE.txt README.md

.PHONY: test
test: build fmtpolice test-deps test-race coverage.html

.PHONY: test-deps
test-deps:
	$(GO) test -i $(GOBUILD_LDFLAGS) $(PACKAGE) $(SUBPACKAGES)

.PHONY: test-race
test-race:
	$(GO) test -race $(GOBUILD_LDFLAGS) $(PACKAGE) $(SUBPACKAGES)

coverage.html: coverage.out
	$(GO) tool cover -html=$^ -o $@

coverage.out: path-coverage.out upload-coverage.out env-coverage.out logging-coverage.out artifact-coverage.out
	$(GO) test -covermode=count -coverprofile=$@.tmp $(GOBUILD_LDFLAGS) $(PACKAGE)
	echo 'mode: count' > $@
	grep -h -v 'mode: count' $@.tmp >> $@
	rm -f $@.tmp
	grep -h -v 'mode: count' $^ >> $@
	$(GO) tool cover -func=$@

path-coverage.out:
	$(GO) test -covermode=count -coverprofile=$@ $(GOBUILD_LDFLAGS) $(PACKAGE)/path

upload-coverage.out:
	$(GO) test -covermode=count -coverprofile=$@ $(GOBUILD_LDFLAGS) $(PACKAGE)/upload

env-coverage.out:
	$(GO) test -covermode=count -coverprofile=$@ $(GOBUILD_LDFLAGS) $(PACKAGE)/env

logging-coverage.out:
	$(GO) test -covermode=count -coverprofile=$@ $(GOBUILD_LDFLAGS) $(PACKAGE)/logging

artifact-coverage.out:
	$(GO) test -covermode=count -coverprofile=$@ $(GOBUILD_LDFLAGS) $(PACKAGE)/artifact

USAGE.txt: build
	$${GOPATH%%:*}/bin/artifacts help | grep -v -E '^VERSION|\s+v\d\.\d\.\d' > $@

UPLOAD_USAGE.txt: build
	$${GOPATH%%:*}/bin/artifacts help upload > $@

README.md: USAGE.txt UPLOAD_USAGE.txt README.md.in $(shell git ls-files '*.go')
	./build-readme < README.md.in > README.md

.gox-bootstrap:
	$(GOX) -build-toolchain > $@

.PHONY: build
build: deps
	$(GO) install $(GOBUILD_FLAGS) $(GOBUILD_LDFLAGS) $(PACKAGE)

.PHONY: crossbuild
crossbuild: deps .gox-bootstrap
	$(GOX) $(GOX_FLAGS) $(GOBUILD_FLAGS) $(GOBUILD_LDFLAGS) $(PACKAGE)

.PHONY: deps
deps:
	$(GO) get $(GOBUILD_FLAGS) $(GOBUILD_LDFLAGS) $(PACKAGE)
	$(GO) get github.com/mitchellh/gox
	$(GODEP) restore

.PHONY: clean
clean:
	rm -vf $${GOPATH%%:*}/bin/artifacts
	rm -vf coverage.html *coverage.out
	$(GO) clean $(PACKAGE) $(SUBPACKAGES) || true
	if [ -d $${GOPATH%%:*}/pkg ] ; then \
		find $${GOPATH%%:*}/pkg -name '*artifacts*' | xargs rm -rfv || true; \
	fi
	rm -rvf ./build

.PHONY: save
save:
	$(GODEP) save -copy=false

.PHONY: fmtpolice
fmtpolice:
	set -e; for f in $(shell git ls-files '*.go'); do gofmt $$f | diff -u $$f - ; done
