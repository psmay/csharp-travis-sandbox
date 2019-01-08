#!/bin/bash

export TOP="`pwd`"
export SCRIPTS="$TOP/scripts"
export DOCFX_PROJECT_DIR="$TOP/docfx_project"
export TEMPDIR="`mktemp -d`" &&
cd "$TEMPDIR"	&&
export DOCFX_EXE="`"$SCRIPTS/install_docfx_console_here.sh"`" &&
"$SCRIPTS/build_documentation.sh"
