#!/bin/bash

. scripts/functions.bash

# Set DOCFX_EXE to the output of install_docfx_console_here.sh
# Set DOCFX_PROJECT_DIR to the absolute path containing docfx.json

require_variable DOCFX_EXE
require_variable DOCFX_PROJECT_DIR

cd "$DOCFX_PROJECT_DIR" &&
mono "$DOCFX_EXE" metadata docfx.json &&
mono "$DOCFX_EXE" build docfx.json
