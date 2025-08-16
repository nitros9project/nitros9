#!/bin/bash
#
# Build lwtools from source
#
mkdir -p lwtools
cd lwtools
wget http://www.lwtools.ca/releases//lwtools/lwtools-4.24.tar.gz
tar xvf lwtools-4.24.tar.gz
cd lwtools-4.24/
sudo make install
