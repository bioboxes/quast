path  := PATH=$(abspath ./vendor/python/bin):$(shell echo "${PATH}")
image := biobox_testing/quast

test: .image
	@TMPDIR=$(abspath tmp) $(path) \
	       biobox verify assembler_benchmark $(image) --verbose

.image: $(shell find image -type f )
	@docker build --tag $(image) .
	@touch $@

bootstrap: vendor/python
	@mkdir -p tmp

vendor/python:
	@mkdir -p log
	@virtualenv $@ 2>&1 > log/virtualenv.txt
	@$(path) pip install biobox-cli==0.4.0
	@touch $@

.PHONY: test bootstrap
