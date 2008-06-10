#!/usr/bin/perl

@stdin = <STDIN>;
shift(@stdin);
shift(@stdin);
$title = " - $stdin[1]";

for ($i=0; $i<@stdin; $i++) {
	$stdin[$i] =~ s/^([A-Z].+)\n+/<\/pre><h3>$1<\/h3><pre>/g;
	$stdin[$i] =~ s/\s([^\s]+)\(([1-9])\)/ <a href=..\/man$2\/$1.html>$1($2)<\/a>/g;
	$stdin[$i] =~ s/\s[<]?([a-zA-Z]+):\/\/([^\s>]+)[>]?/ <a href=$1:\/\/$2>$1:\/\/$2<\/a>/g;
	if ($stdin[$i] =~ /^\s*<\/pre>/) {
		# Remove blank lines preceding a line starting with </pre>
		if ($stdin[$i-1] =~ /^\s*$/) {
			splice(@stdin, $i-1, 1);
			$i--;
		}
	}
	if ($stdin[$i] =~ /^\s*<\/pre>/ && $stdin[$i-1] =~ /<pre>\s*$/) {
		$stdin[$i-1] =~ s/<pre>\s*$//;
		$stdin[$i] =~ s/^\s*<\/pre>//;
	}
}

$save = $/;
undef($/);
open(FH, "../public_html/above.html");
$above = <FH>;
$above =~ s/\$title/$title/g;
close(FH);
open(FH, "../public_html/below.html");
$below = <FH>;
close(FH);
$/ = $save;


unshift(@stdin, $above);
push(@stdin, $below);

print("@stdin");
