#!/usr/bin/perl

use warnings;
use strict;
use Carp;
use 5.010;

sub parse {
	my $input = shift;
	for($input) {
		if(not defined) { return 'blank'; }
		s/^\s+|\s+$//g;
		if(/^$/s) { return 'blank'; }
		elsif(/^(?:y|yes|true|on)$/is) { return 'true'; }
		elsif(/^(?:n|no|false|off)$/is) { return 'false'; }
		elsif(/^([+-]?\d+)$/s) { return (0 + $1) ? 'true' : 'false'; }
		else { return 'invalid'; }
	}
}

sub get_env_flag {
	my $name = shift;
	my $value = $ENV{$name};
	my $parsed = parse($value);
	if($parsed eq 'invalid') {
		croak "$0: Setting '$name' has invalid value '$value'.\n";
	}
	return { blank => undef, true => 1, false => 0 }->{$parsed};
}

sub maybe_allow {
	my $subname = shift;
	my $default_value = shift;

	my $allowed = get_env_flag("ALLOW_$subname");
	my $result = $ENV{"IF_$subname"};

	if(not defined $allowed and defined $result and $result ne '') {
		$allowed = 1;
	}

	return undef if not $allowed;
	return $result // $default_value;
}

sub map_to_result {
	my $input = shift;
	my $parsed = shift;
	my $variable_name = shift;

	my $variable_name_insert = defined($variable_name) ? "$variable_name " : "";

	if($parsed eq 'true') {
		return $ENV{IF_TRUE} // 'true';
	}
	elsif($parsed eq 'false') {
		return $ENV{IF_FALSE} // 'false'
	}
	elsif($parsed eq 'blank') {
		my $result = maybe_allow("BLANK", "");

		if(not defined $result) {
			die "Required boolean variable ${variable_name_insert}has not been set.\n";
		}

		return $result;
	}
	else {
		my $result = maybe_allow("INVALID", $input);

		if(not defined $result) {
			die "Boolean variable ${variable_name_insert}has invalid value '$input'.\n";
		}

		return $result;
	}
}

my $input = $ARGV[0];
my $parsed = parse($input);
say map_to_result($input, $parsed, $ENV{VARIABLE_NAME});
