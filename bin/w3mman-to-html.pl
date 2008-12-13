#!/usr/bin/perl

##############################################################################
# This is the Ubuntu manpage repository generator and interface.
# 
# Copyright (C) 2008 Canonical Ltd.
# 
# This code was originally written by Dustin Kirkland <kirkland@ubuntu.com>,
# based on a framework by Kees Cook <kees@ubuntu.com>.
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# On Debian-based systems, the complete text of the GNU General Public
# License can be found in /usr/share/common-licenses/GPL-3
##############################################################################

use warnings;
use strict;
use CGI qw/escapeHTML/;

my @stdin = <STDIN>;
shift(@stdin);
shift(@stdin);
my $title = escapeHTML($stdin[1]);

for (my $i=0; $i<@stdin; $i++) {
	$stdin[$i] =~ s/</&lt;/g;
# The following line would ideally be used instead, however it seems
# to be too greedy with its escaping...
#	$stdin[$i] =~ escapeHTML($stdin[$i]);
	$stdin[$i] =~ s/^([A-Z].+)\n+/<\/pre><h3>$1<\/h3><pre>/g;
	$stdin[$i] =~ s/\s([^\s]+)\(([1-9])\)/ <a href=\"..\/man$2\/$1.$2.html\">$1($2)<\/a>/g;
	$stdin[$i] =~ s/\s[<]?([a-zA-Z]+):\/\/([^\s>]+)[>]?/ <a href=\"$1:\/\/$2\">$1:\/\/$2<\/a>/g;
	$stdin[$i] =~ s/\xe2\x94\xe2\x94\x82/|/g;		# pipe
	$stdin[$i] =~ s/\xe2\x80\xe2\x80\x98/&#8216;/g; 	# left quote
        $stdin[$i] =~ s/\xe2\x80\xe2\x80\x99/&#8217;/g;		# right quote
	if ($i>0 && $stdin[$i] =~ /^\s*<\/pre>/) {
		# Remove blank lines preceding a line starting with </pre>
		if ($stdin[$i-1] =~ /^\s*$/) {
			splice(@stdin, $i-1, 1);
			$i--;
		}
	}
}

my $pkg = $ARGV[0];
my $src_pkg = $ARGV[1] . "/" . $pkg;
$src_pkg =~ s/_.*$//g;

unshift(@stdin, '<!--#include virtual="/above2.html" -->Provided by: <a href="http://launchpad.net/ubuntu/+source/' . $src_pkg . '">' . $pkg . '</a><pre>');
unshift(@stdin, $title);
unshift(@stdin, '<!--#include virtual="/above1.html" -->');
push(@stdin, '</pre><!--#include virtual="/below.html" -->');

print("@stdin");
