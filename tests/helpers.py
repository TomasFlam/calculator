import subprocess as _subprocess

import pytest

PIPE = _subprocess.PIPE


def cases(cases):
    return pytest.mark.parametrize('_, case', ((str(c), c) for c in cases))


class _Valgrind:
    use = False
    verbose = False


def valgrind(*argv):
    valgrind_argv = [
        'valgrind',
        '--error-exitcode=111',
        '--leak-check=full',
        '--track-origins=yes',
    ]
    if _Valgrind.verbose:
        valgrind_argv.append('-v')
    valgrind_argv.extend(argv)
    return tuple(valgrind_argv)


def maybe_valgrind(*argv):
    if _Valgrind.use:
        return valgrind(*argv)
    return argv


def run(argv, *args, **kwargs):
    return _subprocess.run(maybe_valgrind(*argv), *args, **kwargs)
