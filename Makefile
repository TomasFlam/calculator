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

RUN_ALPINE := docker run --rm $(IMAGE_ALPINE)

PROGRAMS := acalc

all: $(PROGRAMS)

.PHONY: run-tests
run-tests: all
	@section 'Tests' && verbose py.test --cov utils

.PHONY: run-tests-alpine
run-tests-alpine: docker-image-alpine
	@verbose $(RUN_ALPINE) make run-tests

.PHONY: run-tests-all
run-tests-all: run-tests run-tests-alpine

.PHONY: gcovr
gcovr: clean-coverage run-tests
	@verbose gcovr -s

.PHONY: gcovr-alpine
gcovr-alpine: docker-image-alpine
	@verbose $(RUN_ALPINE) make gcovr

.PHONY: gcovr-all
gcovr-all: gcovr gcovr-alpine

.PHONY: docker-image-alpine
docker-image-alpine:
	@verbose docker build -t $(IMAGE_ALPINE) -f Dockerfile.alpine .

.PHONY: check-conventions
check-conventions:
	@section 'Conventions' && verbose utils/check-conventions

.PHONY: flake8
flake8:
	@section 'Flake8' && verbose --only-failure flake8 $(PYTHON_FILES)

.PHONY: ci-stage-lint
ci-stage-lint: check-conventions flake8

.PHONY: ci-stage-test
ci-stage-test: gcovr gcovr-alpine

.PHONY: ci-travis
ci-pipeline: ci-stage-lint ci-stage-test

.PHONY: pip-install
pip-install:
	@verbose pip install -r requirements.txt -U --upgrade-strategy=eager

.PHONY: clean-coverage
clean-coverage:
	rm -f *.gcda *.gcov

.PHONY: clean
clean: clean-coverage
	rm -rf *.[ios] *.gcno $(PROGRAMS)
