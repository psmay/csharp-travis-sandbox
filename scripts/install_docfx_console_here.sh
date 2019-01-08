#!/bin/bash

# Install mono and nuget before running this script

# Install docfx.console
nuget install docfx.console -ExcludeVersion >&2 &&

# Why the next two lines? See https://github.com/dotnet/docfx/issues/3389
nuget install SQLitePCLRaw.core -ExcludeVersion >&2 &&
cp SQLitePCLRaw.core/lib/net45/SQLitePCLRaw.core.dll docfx.console/tools/ >&2 &&

# Print out the location of the exe
echo "`pwd`/docfx.console/tools/docfx.exe"
