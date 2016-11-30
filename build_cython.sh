#!/bin/bash
cython _numpskulls.pyx && 
  gcc -shared -pthread -fPIC -fwrapv -O3 -Wall \
  -fno-strict-aliasing $(python-config --includes) \
  -o _numpskulls.so _numpskulls.c
