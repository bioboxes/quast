#!/bin/bash

set -o errexit
set -o nounset

PACKAGES='make g++ libboost-dev'
URL='https://github.com/ablab/quast/archive/release_4.1.tar.gz'
DIR='/usr/local/quast'

apt-get install --yes ${PACKAGES}

mkdir ${DIR}
cd ${DIR}
wget \
	--quiet \
	--no-check-certificate ${URL} \
	--output-document - |\
tar xzf - \
	--directory . \
	--strip-components=1

cd ${DIR}/libs/E-MEM-linux && make -j $(nproc)
cd ${DIR}/libs/bowtie2 && make -j $(nproc)

# These are not currently used in the QUAST biobox
rm -fr ${DIR}/MUMmer3.23* ${DIR}/gage*

apt-get --purge autoremove --yes ${PACKAGES}
