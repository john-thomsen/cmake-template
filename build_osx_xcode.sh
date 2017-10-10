#!/bin/sh

rm -rf build/
cmake -H. -Bbuild  -GXcode -DCMAKE_BUILD_TYPE=MinSizeRel -DOSX=True
cd build
xcodebuild -target example_shared -configuration MinSizeRel
