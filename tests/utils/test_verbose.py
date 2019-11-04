import subprocess

from tests import helpers as h
from tests.paths import LIB_SH


class Case:
    def __init__(self, args, rc, stdout, stderr):
        self.args = args
        self.rc = rc
        self.stdout = stdout.encode()
        self.stderr = stderr.encode()

    def __str__(self):
        return self.args.replace(' ', '~')


def cases():
    yield Case('', 0, '', h.cyan("$ ''") + '\n' + h.green("0 ''") + '\n')
    yield Case(
        'echo a', 0, 'a\n',
        h.cyan('$ echo a') + '\n' + h.green('0 echo a') + '\n',
    )
    yield Case(
        'false', 1, '',
        h.cyan('$ false') + '\n' + h.red('1 false') + '\n',
    )
    yield Case(
        '--only-failure false', 1, '',
        h.red('1 false') + '\n',
    )


@h.cases(cases())
def test(_, case):
    c = f'. {LIB_SH}; verbose {case.args}'
    argv = ['bash', '-c', c]
    pr = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert pr.returncode == case.rc
    assert pr.stdout == case.stdout
    assert pr.stderr == case.stderr
