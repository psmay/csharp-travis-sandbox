#!/bin/bash

if [ "-$SKIP_INSTALL_MONO-" != "--" ]; then
	echo Skipping Mono install step. >&2
	exit 0
fi

# Install mono and nuget in a rather ugly fashion
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF &&
sudo apt-get install apt-transport-https &&
echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list &&
sudo apt-get update &&
sudo apt-get install ca-certificates-mono mono-devel msbuild nuget