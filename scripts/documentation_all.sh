#!/bin/bash

. scripts/functions.bash

require_variable TOP
require_variable SCRIPTS
default_variable DOCFX_PROJECT_DIR docfx_project
export DOCFX_PROJECT_DIR="$(realpath "$DOCFX_PROJECT_DIR")"
export INSTALLS="`mktemp -d`"

install_mono &&
export DOCFX_EXE=`(
	cd "$INSTALLS" &&
	bash "$SCRIPTS/install_docfx_console_here.sh"
)` &&
bash "$SCRIPTS/build_documentation.sh" &&
bash "$SCRIPTS/push_documentation.sh"
