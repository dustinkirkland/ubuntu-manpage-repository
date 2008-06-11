#!/bin/bash

DESTDIR="$1"
DEB="$2"
if [ ! -d "$DESTDIR" -o ! -s "$DEB" ]; then
        echo "Usage: $0 [/path/to/manpage/destination/] [/path/to/package.deb]" >&2
        exit 1
fi

#echo "INFO: Looking at package [$DEB]"
name=`echo "$DEB" | sed "s/.*\///g" | sed "s/_.*//g"`
cache_modtime=`(ls -l --time-style=+%s $DESTDIR/.cache/$name 2>/dev/null || echo "0 0 0 0 0 0") | awk '{print $6}'`
deb_modtime=`ls -l --time-style=+%s "$DEB" | awk '{print $6}'`
if [ "$cache_modtime" -ge "$deb_modtime" ]; then
	#echo "INFO: Skipping package [$DEB]"
	exit 1
fi

#echo "INFO: Looking for manpages in [$DEB]"
man=`dpkg-deb -c "$DEB" | egrep "\./usr/share/man/.*\.[0-9]\.gz$" | sed "s/^.*\.\//\.\//"`
if [ -z "$man" ]; then
	# Exit immediately if this package does not contain manpages
	#echo "INFO: No manpages: [$DEB]"
	exit 1
fi

#echo "INFO: Extracting manpages from [$DEB]"
TEMPDIR=`mktemp -d -t doc-XXXXXX`
dpkg-deb -x "$DEB" "$TEMPDIR"
for i in $man; do
	#echo "INFO: Considering entry [$i]"
	i=`echo "$i" | sed "s/.*\.\///"`
	manpage="$TEMPDIR/$i"
	i=`echo $i | sed "s/usr\/share\/man\///"i | sed "s/\.gz$//" | sed "s/\.[0-9]$//"`
	out="$DESTDIR"/"$i".html
	#echo "INFO: Considering manpage [$i]"
	if [ ! -s "$manpage" -o -z "$i" ]; then
		#echo "INFO: Skipping empty manpage [$manpage]"
		continue
	fi
	touch $DESTDIR/.cache/$name
	mkdir -p `dirname "$out"` > /dev/null
	#man "$manpage" 2>/dev/null | col -b > "$out".txt
	#man2html -r "$manpage" > "$out"
	w3mman -l "$manpage" | ./w3mman-to-html.pl > "$out"
	if [ ! -s "$out" ]; then
		# Remove if it's an empty file
		rm -f "$out"
	else
		touch -r "$DEB" "$out"
		echo "INFO: Created manpage [$out]"
	fi
done
rm -rf "$TEMPDIR" 2>/dev/null || ( chmod -R 700 "$TEMPDIR" && rm -rf "$TEMPDIR" )
exit 0
