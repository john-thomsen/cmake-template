#!/bin/sh

rm -rf build
cmake -H. -Bbuild 
cd build
make -j 4
