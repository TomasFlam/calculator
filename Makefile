.DEFAULT_GOAL := all

CFLAGS += -O0
CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -Wpedantic
CFLAGS += -fprofile-arcs
CFLAGS += -ftest-coverage

IMAGE_ALPINE = tomasflam/acalc-alpine

RUN_ALPINE = docker run --rm $(IMAGE_ALPINE)

PROGRAMS = acalc

all: $(PROGRAMS)

.PHONY: run-tests-local
run-tests-local: all
	py.test --color=yes

.PHONY: run-tests-alpine
run-tests-alpine: docker-image-alpine
	$(RUN_ALPINE) make run-tests-local

.PHONY: run-tests-all
run-tests-all: run-tests-local run-tests-alpine

.PHONY: gcovr-local
gcovr-local: clean-coverage run-tests-local
	gcovr -s

.PHONY: gcovr-alpine
gcovr-alpine: docker-image-alpine
	$(RUN_ALPINE) make gcovr-local

.PHONY: gcovr-all
gcovr-all: gcovr-local gcovr-alpine

.PHONY: docker-image-alpine
docker-image-alpine:
	docker build -t $(IMAGE_ALPINE) -f Dockerfile.alpine .

.PHONY: pip-install
pip-install:
	pip install -r requirements.txt -U --upgrade-strategy=eager

.PHONY: clean-coverage
clean-coverage:
	rm -f *.gcda *.gcov

.PHONY: clean
clean: clean-coverage
	rm -rf *.[ios] *.gcno $(PROGRAMS)
