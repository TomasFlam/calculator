import typing

from tests import helpers as h
from tests import paths


class Case:
    def __init__(self, name: str, argv: typing.Iterable):
        self.name = name
        self.argv = tuple(argv)


def cases():
    yield Case('too few arguments', [])
    yield Case('too much arguments', ['', ''])


@h.cases(cases())
def test(_, case: Case):
    argv = [paths.ACALC]
    argv.extend(case.argv)
    pr = h.run(argv, stdout=h.PIPE)
    assert pr.returncode == 0
