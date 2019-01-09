
if [ "`type -t _SCRIPT_A436F9D0_33E7_472B_80FA_671AD9EFB47B`" = "function" ]; then
	echo "Warning: Attempted to load $BASH_SOURCE twice" >&2
	return
fi
_SCRIPT_A436F9D0_33E7_472B_80FA_671AD9EFB47B () {
	echo "$BASH_SOURCE"
}

# Echoes to stderr
eecho () {
	echo "$@" >&2
}

die () {
	if [ "-$@-" != "--" ]; then
		eecho "$@"
	fi

	if [ "-$EXIT_CODE-" = "--" ]; then
		exit 2
	else
		exit $EXIT_CODE
	fi
}

# require_variable variable_name
# Dies if the named variable is undefined or blank
require_variable () {
	local variable_name="$1"
	if [ "-${!variable_name}-" = "--" ]; then
		die "Required variable $variable_name is not set."
	fi
}

# default_variable variable_name default_value
# Sets the named variable to default_value if it is undefined or blank 
default_variable () {
	local variable_name="$1"
	local default_value="$2"
	if [ "-${!variable_name}-" = "--" ]; then
		printf -v $variable_name '%s' "$default_value"
	fi
}

bool () {
	# Accepts true/false/yes/no/on/off/1/0
	# Outputs true/false
	# Rejects blank values and non-boolean-looking-values with an error

	# Use IF_TRUE/IF_FALSE to change output for true/false values
	# Use ALLOW_BLANK to allow blank/undefined values without error
	# Use IF_BLANK to change output for blank/undefined values (defaults to "")
	# (Non-blank IF_BLANK implies ALLOW_BLANK)
	# Use ALLOW_INVALID to allow invalid (non-blank, non-boolean) values without error
	# Use IF_INVALID to change output for invalid values (defaults to same as input)
	# (Non-blank IF_INVALID implies ALLOW_INVALID)
	# Set VARIABLE_NAME to include variable name in error messages
	perl "$SCRIPTS/normal_boolean.pl" "$@"
}

variable_bool () {
	local variable_name="$1"
	VARIABLE_NAME="$variable_name" bool "${!variable_name}"
}

# Prints each argument on a separate line
print_on_separate_lines () {
	for i in "$@"; do
		printf '%s\n' "$i"
	done
}

# least_version $a $b $c ...
# Prints out the lowest version number in the parameter list
least_version () {
	print_on_separate_lines "$@" | sort -V | head -n 1
}

# version_le $a $b
# Returns true if 
version_le () {
	local result="`least_version "$1" "$2"`"
	[ "$1" = "$result" ]
}

sort_versions () {
	(for i in "$@"; do printf '%s\n' "$i"; done) | sort -V
}


mono_version () {
	local version_output="`mono --version 2>/dev/null`"
	local version=""
	if [ $? ]; then
		version="`echo "$version_output" | perl -E 'while(<>) { / version (\d\S+)/ and print $1 and exit }'`"
	else
		version=""
	fi
	echo -n "$version"
	[ "$version" != "" ]
}

install_mono_always () {
	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF &&
	sudo apt-get install apt-transport-https &&
	echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list &&
	sudo apt-get update &&
	sudo apt-get install ca-certificates-mono mono-devel msbuild nuget
}

install_mono () {
	local skip=`IF_BLANK=false variable_bool SKIP_INSTALL_MONO` &&
	if [ "$skip" = "" ]; then
		die
	elif [ "$skip" = "true" ]; then
		eecho Skipping Mono install step.
	else
		default_variable MINIMUM_MONO_VERSION 5.0.0
		if version_le $MINIMUM_MONO_VERSION `mono_version`; then
			eecho "Existing Mono version `mono_version` is greater than $MINIMUM_MONO_VERSION; will not install Mono."
		else
			install_mono_always
		fi
	fi
}

if [ "-$SCRIPTS-" = "--" ]; then
	export SCRIPTS="$(dirname "$(realpath "$BASH_SOURCE")")"
	eecho "SCRIPTS set to $SCRIPTS"
fi

if [ "-$TOP-" = "--" ]; then
	if [ "-$TRAVIS_BUILD_DIR-" = "--" ]; then
		export TOP="`realpath "$SCRIPTS/../"`"
	else
		export TOP="`realpath "$TRAVIS_BUILD_DIR"`"
	fi
	eecho "TOP     set to $TOP"
fi
