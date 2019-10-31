import subprocess

from tests import helpers as h
from tests import paths as _paths


class Case:
    def __init__(self, name, argv, rc, stdout):
        self.name = name
        self.argv = argv
        self.rc = rc
        self.stdout = stdout

    def __str__(self):
        return f'name={self.name}:rc={self.rc}:stdout={self.stdout}'


def yellow(x):
    return f'\x1b[33m{x}\x1b[0m'


def cases():
    abc = yellow('abc')

    yield Case('missing_section', [], 2, '')
    yield Case('delimiter_empty', ['-d', '', 'abc'], 2, '')
    yield Case('delimiter_too_long', ['-d', '==', 'abc'], 2, '')
    yield Case(
        'ok_delimiter_default', ['abc'], 0, f'===\n{abc}\n===\n',
    )
    yield Case(
        'ok_delimiter_dash', ['-d', '-', 'abc'], 0, f'---\n{abc}\n---\n',
    )
    yield Case(
        'ok_delimiter_dash', ['--delim', '-', 'abc'], 0, f'---\n{abc}\n---\n',
    )


@h.cases(cases())
def test(_, case):
    argv = [_paths.utils.joinpath('section')]
    argv.extend(case.argv)
    pr = subprocess.run(argv, stdout=subprocess.PIPE)
    assert pr.returncode == case.rc
    assert pr.stdout.decode() == case.stdout
