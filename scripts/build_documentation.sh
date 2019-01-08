#!/bin/bash

# Set DOCFX_EXE to the output of install_docfx_console_here.sh
# Set DOCFX_PROJECT_DIR to the absolute path containing docfx.json

if [ "-$DOCFX_EXE-" = "--" ]; then
	echo DOCFX_EXE is not set. >&2
	exit 2
fi

if [ "-$DOCFX_PROJECT_DIR-" = "--" ]; then
	echo DOCFX_PROJECT_DIR is not set. >&2
	exit 3
fi

cd "$DOCFX_PROJECT_DIR" &&
mono "$DOCFX_EXE" metadata docfx.json &&
mono "$DOCFX_EXE" build docfx.json
