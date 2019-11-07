from tests import helpers as _helpers


def pytest_addoption(parser):
    parser.addoption(
        '--valgrind',
        action='store_true',
    )
    parser.addoption(
        '--valgrind-verbose',
        action='store_true',
    )


def pytest_configure(config):
    if config.getoption('valgrind'):
        _helpers._Valgrind.use = True

    if config.getoption('valgrind_verbose'):
        _helpers._Valgrind.verbose = True
