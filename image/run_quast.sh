#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

TASK=$1
OUTPUT=/bbx/output
INPUT=/bbx/input/biobox.yaml
METADATA=/bbx/metadata
WORK_DIR=$(mktemp -d)

# Run the given task
CMD=$(egrep ^${TASK}: /Taskfile | cut -f 2 -d ':')
if [[ -z ${CMD} ]]; then
  echo "Abort, no task found for '${TASK}'."
  exit 1
fi

# if /bbx/metadata is mounted create log.txt
if [ -d "$METADATA" ]; then
  CMD="($CMD) >& $METADATA/log.txt"
fi

# Input contig FASTA location
CONTIGS=$(biobox_args.sh 'select(has("fasta")) | .fasta | map(.value) | join(" ")')

# QUAST labels
LABELS=$(biobox_args.sh 'select(has("fasta")) | .fasta | map(.id | tostring) | join(",") | "-l \(.)"')

# Path to reference genome directories
REF_PATH=$(biobox_args.sh 'select(has("fasta_dir")) | .fasta_dir | map(.value) | join(" ")')

# List reference paths if defined
if [ ! -z "$REF_PATH" ]; then
        REFERENCES=" -R $(find $REF_PATH -type f | head -c -1 | tr '\n' ',')"
else
	REFERENCES=""
fi

# check if cache is defined
CACHE=$(biobox_args.sh 'select(has("cache")) | .cache ')

if [ ! -z "$CACHE" ]; then
        WORK_DIR=$CACHE
fi

quast() {
	set -o nounset
	local QUAST_OUT=$1
	local QUAST_VERSION=$2
	local COMBINED_OUTPUT=${WORK_DIR}/${QUAST_OUT}

	python /usr/local/quast/${QUAST_VERSION} ${LABELS} ${REFERENCES} --threads `nproc` --output-dir ${COMBINED_OUTPUT} ${CONTIGS}
	cp -r ${COMBINED_OUTPUT}/report.tsv ${OUTPUT}
	cp -r ${COMBINED_OUTPUT} ${OUTPUT}

	cat << EOF > ${OUTPUT}/biobox.yaml
version: 0.9.0
arguments:
  - name: HTML
    type: html
    inline: false
    value: ${QUAST_OUT}/report.html
    description: A summary of multiple metrics.
EOF

}

eval ${CMD}
chmod -R a+rw  "${OUTPUT}"
