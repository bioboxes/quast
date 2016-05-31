#!/bin/bash

set -o errexit
set -o nounset

PACKAGES='make g++'
URL='https://s3-us-west-1.amazonaws.com/bioboxes-packages/downloads/quast-3.2.tar.xz'
DIR='/usr/local/quast'

apt-get install --yes ${PACKAGES}

mkdir ${DIR}
cd ${DIR}
wget \
	--quiet \
	--no-check-certificate ${URL} \
	--output-document - |\
tar xJf - \
	--directory . \
	--strip-components=1

cd libs/MUMmer3.23-linux
make CPPFLAGS="-O3 -DSIXTYFOURBITS"

apt-get --purge autoremove --yes ${PACKAGES}
