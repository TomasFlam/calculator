import functools as _functools
import os.path

# directories
tests = _functools.partial(os.path.join, os.path.dirname(__file__))
project_root = _functools.partial(tests, os.path.pardir)

# files
ACALC = project_root('acalc')
