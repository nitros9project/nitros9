#!/bin/bash
#
# Build the primary NitrOS-9 product recipes from source
#
ls -al
export NITROS9DIR="$(pwd)"

make -C recipes/coco/floppy
make -C recipes/coco/dw
make -C recipes/coco3/floppy
make -C recipes/coco3/dw
