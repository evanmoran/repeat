#!/usr/bin/env perl

use 5.012;
use strict;
use warnings;

use Test::More tests => 14;

my $repeat = '../repeat';
my $tsv = 'fixtures/abc.tsv';
my $csv = 'fixtures/abc.csv';
my $ssv = 'fixtures/abc.ssv';
my $wsv = 'fixtures/abc.wsv';
my $user = 'fixtures/user.tsv';

sub lines {
  return join("\n", @_) . "\n";
}

# my $out = `$repeat '#2' $csv --comma`;
# print "\n\n###$out###\n\n";

# my $out2 = lines('a2', 'b2', '', 'd2');
# print "\n\n###$out2###\n\n";


# ---- Testing version ----
my $version = trim(`$repeat --version`);
my $versionFile = '-1';
$versionFile = $1 if(`cat $repeat` =~ /repeat v(\d+.\d+.*)\n/);
ok $versionFile eq $version, 'Version matches file';

# ---- Testing help and usage ----
ok `$repeat --help` =~ /.*repeat format \[options\] \[files\.\.\.\].*/, 'Help outputs correctly';
ok `$repeat` =~ /.*repeat format \[options\] \[files\.\.\.\].*/, 'Usage outputs correctly';
# ---- Testing seperator parsing ----

# Tab
ok `$repeat '#1' $tsv` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 tsv';
ok `$repeat '#1' $tsv --tab` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 tsv --tab';
ok `$repeat '#1' $tsv --separator '\\t'` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 tsv --separator '\\t'";

# Comma
ok `$repeat '#1' $csv --comma` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 csv --comma';
ok `$repeat '#1' $csv --separator ','` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 csv --separator ','";

# Tabs (all at once)
ok `$repeat '#1' $csv --comma` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 csv --comma';
ok `$repeat '#1' $csv --separator ','` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 csv --separator ','";
ok `$repeat '#2' $csv --comma` eq lines('a2', 'b2', '', 'd2'), 'arg2 csv --comma, should find blank at c2';

# Spaces (all at once)

# Whitespace
ok `$repeat '#1' $wsv --whitespace` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 wsv --whitespace';
ok `$repeat '#1' $wsv --separator '\\s+'` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 wsv --separator '\\s+'";
ok `$repeat '#2' $wsv --whitespace` eq lines('a2', 'b2', 'c3', 'd2'), "arg2 wsv --whitespace, should grab multiple kinds of whitespace.";

# ---- Testing separator parsing ----



# # ok $foo == 5, 'Foo was assigned 5.';
# # ok $bar == 6, 'Bar was assigned 6.';
# ok $foo + $bar == 11, 'Addition works correctly.';


#   trim
# --------------------------------------------------------------------
#   Get string

sub trim
{
  my $str = shift;
  if(defined($str)){
    $str =~ s/^\s+//g;
    $str =~ s/\s+$//g;
  }
  return $str;
}
