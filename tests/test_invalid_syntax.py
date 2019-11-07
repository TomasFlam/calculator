from tests import errors
from tests import helpers as h
from tests import paths


class Case:
    def __init__(self, name: str, expression: str):
        self.name = name
        self.expression = expression

    def __str__(self):
        return f'{self.name}:{self.expression}'


def cases_integers():
    yield Case('integer-integer', '0 1')


@h.cases(cases_integers())
def test(_: str, case: Case):
    argv = [paths.ACALC]
    pr = h.run(argv, input=case.expression.encode(), stdout=h.PIPE)
    assert pr.returncode == errors.INVALID_SYNTAX
