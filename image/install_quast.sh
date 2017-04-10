#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

ESSENTIAL='libsys-info-base-perl libgomp1'
BUILD_PACKAGES='make csh g++ less libboost-all-dev zlib1g-dev ca-certificates'

URL='https://github.com/ablab/quast/archive/quast_4.5.tar.gz'
DIR='/usr/local/quast'

apt-get install --no-install-recommends --yes ${ESSENTIAL} ${BUILD_PACKAGES}
#apt-get upgrade -y libstdc++6

apt-get update && apt-get install -y pkg-config libfreetype6-dev libpng-dev

mkdir ${DIR}
cd ${DIR}
wget \
	${URL} \
	--quiet \
	--output-document - |\
tar xzf - \
	--directory . \
	--strip-components=1

cd ${DIR}/quast_libs/MUMmer && make -j $(nproc)
cd ${DIR}/quast_libs/bwa && make -j $(nproc)
cd ${DIR}/quast_libs/glimmer/src/ && make -j $(nproc)
cd ${DIR}

# These directories have been removed to reduce the size of the QUAST
# biobox. If you would like to use the additional functionality included
# please contact the biobox maintainers.
rm -fr ${DIR}/quast_libs/gage ${DIR}/quast_libs/genemark

# Remove this line if you wish to use the QUAST ./install.sh command for testing
rm -fr ${DIR}/test_data ${DIR}/tc_test

# Clean up all files used for building
apt-get autoremove --purge --yes ${BUILD_PACKAGES}
EXTENSIONS=("pyc" "c" "cc" "cpp" "h" "o")
for EXT in "${EXTENSIONS[@]}"
do
	find . -name "*.$EXT" -delete
done

# Ensure that the essential libraries are still installed
apt-get install --no-install-recommends --yes ${ESSENTIAL}
