#!/usr/bin/env perl

use 5.012;
use strict;
use warnings;

use Test::More tests => 58;

# Helpers
# --------------------------------------------------------------------

my $repeat = '../repeat';
my $tsv = 'fixtures/abc.tsv';
my $csv = 'fixtures/abc.csv';
my $ssv = 'fixtures/abc.ssv';
my $wsv = 'fixtures/abc.wsv';
my $user = 'fixtures/user.tsv';

sub lines {
  return join("\n", @_) . "\n";
}

# Version
# --------------------------------------------------------------------

my $version = trim(`$repeat --version`);
my $versionFile = '-1';
$versionFile = $1 if(`cat $repeat` =~ /repeat v(\d+.\d+.*)\n/);
ok $versionFile eq $version, 'Version matches file';

# Help and Usage
# --------------------------------------------------------------------

ok `$repeat --help` =~ /.*repeat \[options\] format \[files\.\.\.\].*/, 'Help outputs correctly';
ok `$repeat` =~ /.*repeat \[options\] format \[files\.\.\.\].*/, 'Usage outputs correctly';

# Execute
# --------------------------------------------------------------------
ok `$repeat 'echo "#{4}" > #{1}.txt' $user` eq lines('echo "Loves fine wine." > Sarah.txt', 'echo "Talks to himself." > Ted.txt', 'echo "Afraid of butterflies." > Britta.txt'), 'execute without executing';
ok `$repeat -x 'echo "#{4}" > #{1}.txt' $user` eq '', 'execute to create files';
ok `$repeat --execute 'cat #{1}.txt' $user` eq "Loves fine wine.\nTalks to himself.\nAfraid of butterflies.\n", 'execute to read files';
ok `$repeat -x -v 'rm #{1}.txt' $user` eq "[rm Sarah.txt]\n[rm Ted.txt]\n[rm Britta.txt]\n", 'execute to rm files verbose';

# Seperator parsing
# --------------------------------------------------------------------

# Tab
ok `$repeat '#1' $tsv` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 tsv';
ok `$repeat '#1' $tsv --tab` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 tsv --tab';
ok `$repeat '#1' $tsv --separator '\\t'` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 tsv --separator '\\t'";
ok `$repeat '#2' $tsv --tab` eq lines('a2', 'b2', '', 'd2'), 'arg2 tsv --tab, should find blank';
ok `$repeat '#3' $tsv --tab` eq lines('a3', 'b3', 'c3', ''), 'arg2 tsv --tab, should find blank';

# Comma
ok `$repeat '#1' $csv --comma` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 csv --comma';
ok `$repeat '#1' $csv --separator ','` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 csv --separator ','";
ok `$repeat '#2' $csv --comma` eq lines('a2', 'b2', '', 'd2'), 'arg2 csv --comma, should find blank';
ok `$repeat '#3' $csv --comma` eq lines('a3', 'b3', 'c3', ''), 'arg2 csv --comma, should find blank';

# Tabs (all at once)
ok `$repeat '#1' $tsv --tabs` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 tsv --tabs';
ok `$repeat '#1' $tsv --separator '\\t+'` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 tsv --separator '\\t+'";
ok `$repeat '#2' $tsv --tabs` eq lines('a2', 'b2', 'c3', 'd2'), 'arg2 tsv --tabs, should not find blank';
ok `$repeat '#3' $tsv --tabs` eq lines('a3', 'b3', '', ''), 'arg3 tsv --tabs, should find blank';

# Spaces (all at once)
ok `$repeat '#1' $ssv --spaces` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 csv --spaces';
ok `$repeat '#1' $ssv --separator ' '` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 csv --separator ','";
ok `$repeat '#2' $ssv --spaces` eq lines('a2', 'b2', 'c3', 'd2'), 'arg2 csv --spaces';
ok `$repeat '#3' $ssv --spaces` eq lines('a3', 'b3', '', ''), 'arg3 csv --spaces';

# Whitespace
ok `$repeat '#1' $wsv --whitespace` eq lines('a1', 'b1', 'c1', 'd1'), 'arg1 wsv --whitespace';
ok `$repeat '#1' $wsv --separator '\\s+'` eq lines('a1', 'b1', 'c1', 'd1'), "arg1 wsv --separator '\\s+'";
ok `$repeat '#2' $wsv --whitespace` eq lines('a2', 'b2', 'c3', 'd2'), "arg2 wsv --whitespace, should not find blank.";
ok `$repeat '#3' $wsv --whitespace` eq lines('a3', 'b3', '', ''), "arg3 wsv --whitespace, should grab multiple kinds of whitespace.";

# String Formatting
# --------------------------------------------------------------------
ok `$repeat '#1' $user ` eq lines('Sarah', 'Ted', 'Britta'), 'strings no formatting';
ok `$repeat '#{1,8s}' $user ` eq lines('   Sarah', '     Ted', '  Britta'), 'strings right align';
ok `$repeat '#{1,-8s}' $user ` eq lines('Sarah   ', 'Ted     ', 'Britta  '), 'strings left align';
ok `$repeat '#{1,0s}' $user ` eq lines('Sarah', 'Ted', 'Britta'), 'strings left align too small';
ok `$repeat '#{1,5s}' $user ` eq lines('Sarah', '  Ted', 'Britta'), 'strings left align inbetween size';

# float Formatting
# --------------------------------------------------------------------
ok `$repeat '#2' $user ` eq lines('74', '12', '2'), 'integer unspecified no formatting';
ok `$repeat '#{2,i}' $user ` eq lines('74', '12', '2'), 'integer specified no formatting ';
ok `$repeat '#{2,04i}' $user ` eq lines('0074', '0012', '0002'), 'integer filled with zeros';
ok `$repeat '#{2,-04i}' $user ` eq lines('74  ', '12  ', '2   '), 'integer filled with zeros uses spaces when left aligned';
ok `$repeat '#{2,6.3i}' $user ` eq lines('   074', '   012', '   002'), 'integer filled with spaces and zeros';

# Float Formatting
# --------------------------------------------------------------------
ok `$repeat '#3' $user ` eq lines('9876.54', '23', '1234.5'), 'float unspecified no formatting';
ok `$repeat '#{3,f}' $user ` eq lines('9876.540000', '23.000000', '1234.500000'), 'float defaults to precision of six';
ok `$repeat '#{3,10f}' $user ` eq lines('9876.540000', ' 23.000000', '1234.500000'), 'float default precision with alignment';
ok `$repeat '#{3,0.0f}' $user ` eq lines('9877', '23', '1234'), 'float zero precision and spacing';
ok `$repeat '#{3,0.1f}' $user ` eq lines('9876.5', '23.0', '1234.5'), 'float one precision and zero spacing';
ok `$repeat '#{3,0.2f}' $user ` eq lines('9876.54', '23.00', '1234.50'), 'float two precision and zero spacing';
ok `$repeat '#{3,0.3f}' $user ` eq lines('9876.540', '23.000', '1234.500'), 'float three precision and zero spacing';
ok `$repeat '#{3,8.1f}' $user ` eq lines('  9876.5', '    23.0', '  1234.5'), 'float eight precision and one spacing';
ok `$repeat '#{3,08.1f}' $user ` eq lines('009876.5', '000023.0', '001234.5'), 'float eight precision and one spacing filled with zeros';
ok `$repeat '#{3,-8.1f}' $user ` eq lines('9876.5  ', '23.0    ', '1234.5  '), 'float eight precision and one spacing left aligned';

# Float Scientific Formatting
# --------------------------------------------------------------------

ok `$repeat '#{3,e}' $user ` eq lines('9.876540e+03', '2.300000e+01', '1.234500e+03'), 'float scientific notation';
ok `$repeat '#{3,0.2e}' $user ` eq lines('9.88e+03', '2.30e+01', '1.23e+03'), 'float scientific notation with precision 2';
ok `$repeat '#{3,10.2e}' $user ` eq lines('  9.88e+03', '  2.30e+01', '  1.23e+03'), 'float scientific notation with precision 2';

# Hex
# --------------------------------------------------------------------

ok `$repeat '#{2,x}' $user ` eq lines('4a', 'c', '2'), 'hex no formatting';
ok `$repeat '#{2,X}' $user ` eq lines('4A', 'C', '2'), 'hex captialized';
ok `$repeat '0x#{2,X}' $user ` eq lines('0x4A', '0xC', '0x2'), 'hex captialized with 0x';

# Binary
# --------------------------------------------------------------------

ok `$repeat '#{2,b}' $user ` eq lines('1001010', '1100', '10'), 'binary no formatting';
ok `$repeat '0b#{2,b}' $user ` eq lines('0b1001010', '0b1100', '0b10'), 'binary no formatting with 0b';
ok `$repeat '#{2,08b}' $user ` eq lines('01001010', '00001100', '00000010'), 'binary fill zeros';
ok `$repeat '0b#{2,08b}' $user ` eq lines('0b01001010', '0b00001100', '0b00000010'), 'binary fill zeros with 0b';

# No Trim
# --------------------------------------------------------------------





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
