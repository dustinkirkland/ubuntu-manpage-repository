#!/bin/bash

. ./config

DIST="$1"
PKG="$2"

DESTDIR="$PUBLIC_HTML_DIR/manpages/$DIST"
DESTDIRGZ="$PUBLIC_HTML_DIR/manpages.gz/$DIST"
DEB="$DEBDIR/$PKG"
NAME=`basename "$PKG" | awk -F_ '{print $1}'`
NAME_AND_VER=`basename "$PKG" | sed "s/\.deb$//"`


#echo "INFO: Looking for manpages in [$DEB]"
man=`dpkg-deb -c "$DEB" | egrep " \./usr/share/man/.*\.[0-9]\.gz$" | sed "s/^.*\.\//\.\//"`
if [ -z "$man" ]; then
	echo "INFO: No manpages: [$DIST] [$PKG]"
	# Touch the cache file so we don't look again until package updated
	touch $DESTDIR/.cache/$NAME
	# Exit immediately if this package does not contain manpages
	exit 0
fi

#echo "INFO: Extracting manpages from [$DEB]"
TEMPDIR=`mktemp -d -t doc-XXXXXX`
dpkg-deb -x "$DEB" "$TEMPDIR"
for i in $man; do
	#echo "INFO: Considering entry [$i]"
	i=`echo "$i" | sed "s/.*\.\///"`
	manpage="$TEMPDIR/$i"
	i=`echo $i | sed "s/usr\/share\/man\///"i | sed "s/\.gz$//" | sed "s/\.[0-9]$//"`
	#echo "INFO: Considering manpage [$i]"
	if [ ! -s "$manpage" -o -z "$i" ]; then
		#echo "INFO: Skipping empty manpage [$manpage]"
		continue
	fi
	out="$DESTDIR"/"$i".html
	outgz=`dirname "$DESTDIRGZ"/"$i"`
	mkdir -p `dirname "$out"` "$outgz" > /dev/null
	#man "$manpage" 2>/dev/null | col -b > "$out".txt
	#man2html -r "$manpage" > "$out"
	w3mman -l "$manpage" | ./w3mman-to-html.pl $NAME_AND_VER > "$out"
	touch $DESTDIR/.cache/$NAME
	cp -f "$manpage" "$outgz"
	if [ -s "$out" ]; then
		echo "INFO: Created manpage [$out]"
	else
		# Remove if it's an empty file
		rm -f "$out"
	fi
done
rm -rf "$TEMPDIR" 2>/dev/null || ( chmod -R 700 "$TEMPDIR" && rm -rf "$TEMPDIR" )
exit 0
