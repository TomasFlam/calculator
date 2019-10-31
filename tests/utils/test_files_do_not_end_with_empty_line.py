import subprocess

from tests import helpers as h
from tests import paths as _paths


class Case:
    def __init__(self, rc, name, contents, stdout):
        self.rc = rc
        self.name = name
        self.contents = contents
        self.stdout = stdout

    def __str__(self):
        return f'{self.rc}:{self.name}'


def cases():
    yield Case(0, 'no_file', [], [])
    yield Case(0, 'empty_file', [''], [])
    yield Case(1, 'just_new_line', ['\n'], [0])
    yield Case(0, 'canonical', ['a\n'], [])
    yield Case(1, 'canonical', ['a\n\n'], [0])
    yield Case(0, '00', ['', 'a\n'], [])
    yield Case(1, '01', ['', '\n'], [1])
    yield Case(1, '10', ['\n', ''], [0])
    yield Case(1, '11', ['\n', 'a\n\n'], [0, 1])


@h.cases(cases())
def test_files_do_not_end_with_empty_line(_: str, case: Case, tmpdir):
    argv = [_paths.utils.joinpath('files-do-not-end-with-empty-line')]

    paths = []
    for i, c in enumerate(case.contents):
        p = tmpdir.join(f'{i}')
        paths.append(p)
        p.write(c)
    argv.extend(paths)

    pr = subprocess.run(argv, stdout=subprocess.PIPE)
    assert pr.returncode == case.rc

    stdout_actual = pr.stdout.decode()
    stdout_expected = ''.join(f'{paths[i]}\n' for i in case.stdout)
    assert stdout_actual == stdout_expected
