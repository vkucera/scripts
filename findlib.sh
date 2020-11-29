#!/bin/bash

# Find C++ library files.

Dir="$PWD"
[ "$1" ] && Dir="$1"

find "$Dir" \
-name "*_C.d" \
-o -name "*_C.so" \
-o -name "*_cc.d" \
-o -name "*_cc.so" \
-o -name "*_cxx.d" \
-o -name "*_cxx.so" \
-o -name "*_cpp.d" \
-o -name "*_cpp.so" \
-o -name "*_h.d" \
-o -name "*_h.so"

exit 0
