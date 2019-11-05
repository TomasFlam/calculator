import functools

from tests import helpers as h
from tests import paths


class Case:
    def __init__(self, name: str, expression: str, expected: str):
        self.name = name
        self.expression = expression
        self.expected = expected

    def __str__(self):
        return f'{self.name}:{self.expression}'


def cases_integers():
    c = functools.partial(Case, 'integer')
    yield c('0', '0\n')
    yield c('1', '1\n')
    yield c('12', '12\n')


@h.cases(cases_integers())
def test(_: str, case: Case):
    argv = [paths.ACALC]
    pr = h.run(argv, input=case.expression.encode(), stdout=h.PIPE)
    assert pr.returncode == 0
    assert pr.stdout.decode() == case.expected
