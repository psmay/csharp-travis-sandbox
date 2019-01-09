#!/bin/bash

export TOP="`pwd`"
export SCRIPTS="$TOP/scripts"
export DOCFX_PROJECT_DIR="$TOP/docfx_project"

bash "$SCRIPTS/install_mono_and_nuget.sh" &&
export TEMPDIR="`mktemp -d`" &&
cd "$TEMPDIR" &&
export DOCFX_EXE="`bash "$SCRIPTS/install_docfx_console_here.sh"`" &&
bash "$SCRIPTS/build_documentation.sh" &&
bash "$SCRIPTS/push_documentation.sh"
