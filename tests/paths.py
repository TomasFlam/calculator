from pathlib import Path as _Path

# directories
tests = _Path(__file__).parent
project_root = tests.parent
utils = project_root.joinpath(project_root, 'utils')

# files
ACALC = project_root.joinpath('acalc')
LIB_SH = project_root.joinpath('lib.sh')
