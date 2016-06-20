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
    path = os.path.join(sys.prefix, 'Library', 'bin', 'libnetcdff.dll')
    lib = ctypes.CDLL(path)
else:
    raise ValueError('Unrecognized platform: {}'.format(platform))
