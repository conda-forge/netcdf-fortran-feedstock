# Load the libraries using ctypes.
import os
import sys
import ctypes

platform = sys.platform

if platform.startswith('linux'):
    path = os.path.join(sys.prefix, 'lib', 'libnetcdff.so')
    lib = ctypes.CDLL(path)
elif platform == 'darwin':
    path = os.path.join(sys.prefix, 'lib', 'libnetcdff.dylib')
    lib = ctypes.CDLL(path)
elif platform == 'win32':
    libdir = os.path.join(sys.prefix, 'Library', 'bin')
    for name in ("netcdff.dll", "libnetcdff.dll"):
        path = os.path.join(libdir, name)
        if os.path.exists(path):
            lib = ctypes.CDLL(path)
            break
    else:
        raise FileNotFoundError(
            f"Could not find netCDF-Fortran DLL (tried netcdff.dll and libnetcdff.dll) in {libdir}"
        )
else:
    raise ValueError('Unrecognized platform: {}'.format(platform))
