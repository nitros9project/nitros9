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
VERSION=4.25
mkdir -p lwtools
cd lwtools
wget http://www.lwtools.ca/releases//lwtools/lwtools-${VERSION}.tar.gz
tar xvf lwtools-${VERSION}.tar.gz
cd lwtools-${VERSION}/
sudo make install
