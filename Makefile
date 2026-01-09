# Nicked this from https://stackoverflow.com/a/17845120
# The purpose is to be able to build/clean (and eventually maybe zip up and
# perhaps also build docs) each code directory.

TOPTARGETS := all clean

SUBDIRS := $(dir $(wildcard */*/Makefile))


$(TOPTARGETS): $(SUBDIRS)

$(SUBDIRS):
	@echo
	@echo $(MAKECMDGOALS)
	$(MAKE) -C $@ $(MAKECMDGOALS)

.PHONY: $(TOPTARGETS) $(SUBDIRS)
