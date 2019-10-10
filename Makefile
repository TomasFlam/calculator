.DEFAULT_GOAL := all

CFLAGS += -O0
CFLAGS += -Wall
CFLAGS += -Wextra
CFLAGS += -Wpedantic
CFLAGS += -fprofile-arcs
CFLAGS += -ftest-coverage

all: acalc

.PHONY: pip-install
pip-install:
	pip install -r requirements.txt -U --upgrade-strategy=eager

.PHONY: clean-coverage
clean-coverage:
	rm -f *.gcda *.gcov

.PHONY: clean
clean: clean-coverage
	rm -rf *.[ios]
