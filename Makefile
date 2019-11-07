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

H1 := section -d =
H2 := section -d -

GCOVR := gcovr -s --fail-under-line 100 --fail-under-branch 100

M = MAKELEVEL=0 $(MAKE)

all: $(PROGRAMS)

scan.c: scan.l

scan.o: CFLAGS :=
scan.o: scan.c

acalc: LDFLAGS += -lfl
acalc: scan.o

.PHONY: run-tests
run-tests: clean-coverage all
	@$(H1) 'Tests' && verbose pytest --cov utils

.PHONY: run-tests-valgrind
run-tests-valgrind: clean-coverage all
	@$(H1) 'Tests (valgrind)' && verbose pytest --cov utils --valgrind

.PHONY: run-tests-valgrind-verbose
run-tests-valgrind-verbose: clean-coverage all
	@$(H1) 'Tests (valgrind verbose)' \
		&& verbose pytest --cov utils --valgrind --valgrind-verbose

.PHONY: docker-image-alpine
docker-image-alpine:
	@verbose $(DOCKER_BUILD) -t $(IMAGE_ALPINE) -f Dockerfile.alpine .

.PHONY: docker-image-ubuntu-bionic
docker-image-ubuntu-bionic:
	@verbose $(DOCKER_BUILD) -t $(IMAGE_UBUNTU_BIONIC) \
		-f Dockerfile.ubuntu.bionic .

.PHONY: pip-install
pip-install:
	@verbose pip install -r requirements.txt -U --upgrade-strategy=eager

.PHONY: clean-coverage-python
clean-coverage-python:
	rm -f .coverage

.PHONY: clean-coverage-gcov
clean-coverage-gcov:
	rm -f *.gcda *.gcov

.PHONY: clean-coverage
clean-coverage: clean-coverage-gcov clean-coverage-python

.PHONY: clean
clean: clean-coverage
	rm -rf *.[ios] *.gcno scan.c $(PROGRAMS)

######
# CI #
######

.PHONY: ci-job-conventions
ci-job-conventions:
	@$(H1) 'Conventions'
	@verbose utils/check-conventions

.PHONY: ci-job-flake8
ci-job-flake8:
	@$(H1) 'Flake8'
	@verbose --only-failure flake8 \
		--application-import-names=tests \
		--import-order-style=pycharm \
		$(PYTHON_FILES)
	@ansi_color 2 && echo OK && ansi_reset

.PHONY: ci-job-tests
ci-job-tests: PYTEST = pytest --cov . --cov-append
ci-job-tests: clean-coverage all
	@$(H1) 'Tests (cover all)'
	@$(H2) 'Without Valgrind'
	@verbose $(PYTEST)
	@verbose $(GCOVR) && $(M) clean-coverage-gcov
	@$(H2) 'With Valgrind'
	@verbose $(PYTEST) --valgrind
	@verbose $(GCOVR) && $(M) clean-coverage-gcov
	@$(H2) 'With Verbose Valgrind'
	@verbose $(PYTEST) \
		--cov-fail-under 100 \
		--valgrind \
		--valgrind-verbose \
		tests/acalc/test_invalid_syntax.py

.PHONY: ci-job-tests-alpine
ci-job-tests-alpine: docker-image-alpine
	@verbose $(RUN_ALPINE) make ci-job-tests

.PHONY: ci-job-tests-ubuntu-bionic
ci-job-tests-ubuntu-bionic: docker-image-ubuntu-bionic
	@verbose $(RUN_UBUNTU_BIONIC) make ci-job-tests

.PHONY: ci-stage-lint
ci-stage-lint: ci-job-conventions ci-job-flake8

.PHONY: ci-stage-tests
ci-stage-tests: \
	ci-job-tests \
	ci-job-tests-alpine \
	ci-job-tests-ubuntu-bionic

.PHONY: ci-travis
ci-travis: ci-stage-lint ci-job-tests

.PHONY: ci-pipeline
ci-pipeline: ci-stage-lint ci-stage-tests
