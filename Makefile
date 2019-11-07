.DEFAULT_GOAL := all

SHELL := bash -e -o pipefail -u
export BASH_ENV := $(CURDIR)/lib.sh

PYTHON_FILES = $(shell git ls-files -- '*.py')
PYTHON_FILES += utils/files-do-not-end-with-empty-line
PYTHON_FILES += utils/section

CFLAGS += -O0
CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -Wpedantic
CFLAGS += -fprofile-arcs
CFLAGS += -ftest-coverage

IMAGE_ALPINE := tomasflam/acalc-alpine
IMAGE_UBUNTU_BIONIC := tomasflam/acalc-ubuntu-bionic

RUN_ALPINE := docker run --rm $(IMAGE_ALPINE)
RUN_UBUNTU_BIONIC := docker run --rm $(IMAGE_UBUNTU_BIONIC)

DOCKER_BUILD = docker build $(DOCKER_BUILD_FLAGS)

PROGRAMS := acalc

all: $(PROGRAMS)

scan.c: scan.l

scan.o: CFLAGS :=
scan.o: scan.c

acalc: LDFLAGS += -lfl
acalc: scan.o

.PHONY: run-tests
run-tests: all
	@section 'Tests' && verbose py.test --cov utils --valgrind

.PHONY: run-tests-alpine
run-tests-alpine: docker-image-alpine
	@verbose $(RUN_ALPINE) make run-tests

.PHONY: run-tests-all
run-tests-all: run-tests run-tests-alpine

.PHONY: gcovr
gcovr: clean-coverage run-tests
	@verbose gcovr -s -e scan.c

.PHONY: gcovr-alpine
gcovr-alpine: docker-image-alpine
	@verbose $(RUN_ALPINE) make gcovr

.PHONY: gcovr-ubuntu-bionic
gcovr-ubuntu-bionic: docker-image-ubuntu-bionic
	@verbose $(RUN_UBUNTU_BIONIC) make gcovr

.PHONY: gcovr-all
gcovr-all: gcovr gcovr-alpine gcovr-ubuntu-bionic

.PHONY: docker-image-alpine
docker-image-alpine:
	@verbose $(DOCKER_BUILD) -t $(IMAGE_ALPINE) -f Dockerfile.alpine .

.PHONY: docker-image-ubuntu-bionic
docker-image-ubuntu-bionic:
	@verbose $(DOCKER_BUILD) -t $(IMAGE_UBUNTU_BIONIC) -f Dockerfile.ubuntu.bionic .

.PHONY: check-conventions
check-conventions:
	@section 'Conventions' && verbose utils/check-conventions

.PHONY: flake8
flake8:
	@section 'Flake8' && verbose --only-failure flake8 $(PYTHON_FILES)

.PHONY: ci-stage-lint
ci-stage-lint: check-conventions flake8

.PHONY: ci-stage-test
ci-stage-test: gcovr-all

.PHONY: ci-travis
ci-travis: ci-stage-lint gcovr

.PHONY: ci-pipeline
ci-pipeline: ci-stage-lint ci-stage-test

.PHONY: pip-install
pip-install:
	@verbose pip install -r requirements.txt -U --upgrade-strategy=eager

.PHONY: clean-coverage
clean-coverage:
	rm -f *.gcda *.gcov

.PHONY: clean
clean: clean-coverage
	rm -rf *.[ios] *.gcno scan.c $(PROGRAMS)
