#!/usr/bin/perl -w
#
# File: create.pl
# Author: Siddharth Chandrasekaran
# Date: Sun Mar 13 21:24:17 2016

use strict;

my $fmt_sh =<< "END";
\#!/bin/sh
\# %s
\#
\# File: %s
\# Author: %s
\# Email: %s
\# Date: %s\n\n
END

my $fmt_csrc =<< "END";
/* %s
 *
 * File: %s
 * Author: %s
 * Email: %s
 * Date: %s
 */\n\n
END

my $fmt_chdr =<< "END";
/* %s
 *
 * File: %s
 * Author: %s
 * Email: %s
 * Date: %s
 */\n\n
\#ifndef %4\$s_H_
\#define %4\$s_H_\n
\#endif /* %4\$s_H_ */\n
END

my $fmt_pl =<< "END";
\#!/usr/bin/perl -w
\# %s
\#
\# File: %s
\# Author: %s
\# Email: %s
\# Date: %s\n
use strict;\n\n
END

my $argc = @ARGV;

sub dieUsage {
	print "Create utility currenly supports only c, h, sh, and pl file extentions\n".
		"Usage:\n".
		"$0 -f <ext> <file> [or]\n".
		"$0 <file.ext>";
	die "\n";
}

my ($file, $fext, $fname);
my $rcFile = "$ENV{'HOME'}/.createrc";
my $opt = shift;
if ($argc == 3) {
	&dieUsage unless ($opt eq "-f");
	($fext, $fname) = @ARGV;
	$file = $fname;
} elsif ($argc == 1) {
	$file = $opt;
	($fname, $fext) = ($file =~ /(.*)\.(.*)/);
} else {
	&dieUsage;
}

print "$file: $fname <=> $fext\n";

die ("Error: File already exists!\n") if -e $file;
die ("Error: Unsupported file extention\n") unless($fext =~ /(c|h|pl|sh)/);

my %fields;
my $dateStr = localtime();
my $license = "";
my $author = "";
my $email = "";
if (-e $rcFile) {
	open (my $rc, "<", $rcFile) 
		or die ("Error reading from " . $ENV{"HOME"} . "/.createrc\n");
	my %fields = ( 'Author', '', 'License', '' );
	while(<$rc>) {
		chomp;
		my ($field, $value) = split /:/, $_;
		chomp $field if defined $field; chomp $value if defined $value;
		next unless(/(Author|License|Email)/);
		$fields{$field} = $value;
	}
	$author  = $fields{'Author'};
	$license = $fields{'License'};
	$email = $fields{'Email'};
	close ($rc);
} else {
	print "Could not find .createrc in home directory\n\nExaple:\n";
	print "Author: Siddharth Chandrasekaran\n";
	print "License: Your licence text goes here\n\n";
}

$license =~ s/(.{0,60}(?:\s|$))/$1\n/g;
$license =~ s/\n*$//;

my $out;
open(my $f, ">", $file) or die ("Error: Unable to create file $file\n");
if ($fext eq "c") {
	$license =~ s/\n/\n \* /gi;
	$out = sprintf($fmt_csrc, $license, $file, $email, $author, $dateStr);
} elsif ($fext eq "h") {
	$license =~ s/\n/\n \* /gi;
	my $tmp = $fname;
	$tmp =~ s/(.*)/\U$1/;
	$out = sprintf($fmt_chdr, $license, $file, $author, $email, $dateStr, $tmp);
} elsif ($fext eq "sh") {
	chmod 0755, $f;
	$license =~ s/\n/\n\# /gi;
	$out = sprintf($fmt_sh, $license, $file, $author, $email, $dateStr);
} elsif ($fext eq "pl") {
	chmod 0755, $f;
	$license =~ s/\n/\n\# /gi;
	$out = sprintf($fmt_pl, $license, $file, $author, $email, $dateStr);
} else {
	die ("Error: Unsupported file extension.\n");
}

print $f $out;
print "New file $file created!\n";

