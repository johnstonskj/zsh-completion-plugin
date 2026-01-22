# -*- mode: makefile-gmake -*-

all: shdoc

DOC_CMD=./mkdoc.zsh
DOC_DIR=doc
DOC_SOURCE=completion.plugin.zsh

$(DOC_DIR):
	mkdir -p $(DOC_DIR)

shdoc: $(DOC_SOURCES) $(DOC_DIR)
	$(DOC_CMD)