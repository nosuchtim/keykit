
"""
pykeykit - keykit module for python
"""

cdef extern from "pykeykit.h":

	cdef int keykit_init(int hwnd, int hinst)
	cdef int keykit_setcallback(object f)
	cdef int keykit_eval(char* s)

import win32con
import sys
import ctypes
import time
from threading import Timer

global Gkeykit

cdef class keydevice:

	cdef int done

	def __new__(self):
		global Gkeykit
		Gkeykit = self
		self.done = 0
	
	def init(self, hwnd, hinst):
		n = keykit_init(hwnd,hinst)
		return n

	def setcallback(self, f):
		keykit_setcallback(f)

	def keyeval(self, s):
		cdef char *cstring
		cstring = s
		n = keykit_eval(cstring)
		return n
