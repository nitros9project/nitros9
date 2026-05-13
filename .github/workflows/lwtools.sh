#!/bin/bash
#
# Build lwtools from source
#
# UPDATING LWTOOLS VERSION
# ~~~~~~~~~~~~~~~~~~~~~~~~
# To update to a new version of lwtools. Change the version number below
# AND also in build.yml. The cached copy will be renewed as its based
# on the "key:"
#
#
mkdir -p lwtools
cd lwtools
wget http://www.lwtools.ca/releases//lwtools/lwtools-4.24.tar.gz
tar xvf lwtools-4.24.tar.gz
cd lwtools-4.24/
sudo make install
