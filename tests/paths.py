from pathlib import Path as _Path

# directories
tests = _Path(__file__).parent
project_root = tests.parent

# files
ACALC = project_root.joinpath('acalc')
