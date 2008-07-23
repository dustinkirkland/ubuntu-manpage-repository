#!/bin/sh

###############################################################################
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
###############################################################################

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
	i=`echo "$i" | sed "s/usr\/share\/man\///i" | sed "s/\.gz$//" | sed "s/\.[0-9]$//"`
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
	w3mman -l "$manpage" | ./w3mman-to-html.pl "$NAME_AND_VER" > "$out"
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
