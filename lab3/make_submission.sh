#!/bin/sh

DIR=lab3_submission

rm -rf $DIR $DIR.zip
mkdir -p $DIR
cp README $DIR
cp -R hw/hdl/verilog/mips $DIR
cd sim/
make clean
cd ..
cp -R sim/tests $DIR
(cd $DIR && zip -r ../$DIR.zip .)
rm -rf $DIR
echo "Submission ready in $DIR.zip"
