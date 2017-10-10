#!/bin/sh

rm -rf build
cmake -H. -Bbuild -DOSX=True 
cd build
make -j 4
