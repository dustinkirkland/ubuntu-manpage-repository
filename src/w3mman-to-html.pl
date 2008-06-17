#!/usr/bin/perl

@stdin = <STDIN>;
shift(@stdin);
shift(@stdin);

for ($i=0; $i<@stdin; $i++) {
	$stdin[$i] =~ s/</&lt;/g;
	$stdin[$i] =~ s/^([A-Z].+)\n+/<\/pre><h3>$1<\/h3><pre>/g;
	$stdin[$i] =~ s/\s([^\s]+)\(([1-9])\)/ <a href=..\/man$2\/$1.html>$1($2)<\/a>/g;
	$stdin[$i] =~ s/\s[<]?([a-zA-Z]+):\/\/([^\s>]+)[>]?/ <a href=$1:\/\/$2>$1:\/\/$2<\/a>/g;
	if ($i>0 && $stdin[$i] =~ /^\s*<\/pre>/) {
		# Remove blank lines preceding a line starting with </pre>
		if ($stdin[$i-1] =~ /^\s*$/) {
			splice(@stdin, $i-1, 1);
			$i--;
		}
	}
}

$pkg = $ARGV[0];
$pkg_name = $ARGV[0];
$pkg_name =~ s/_.*$//g;

unshift(@stdin, '<!--#include virtual="/above.html" -->Provided by: <a href=http://launchpad.net/ubuntu/+source/' . $pkg_name . '>' . $pkg . '</a><pre>');
push(@stdin, '</pre><!--#include virtual="/below.html" -->');

print("@stdin");
