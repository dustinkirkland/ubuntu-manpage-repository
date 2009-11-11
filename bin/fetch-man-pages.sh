#!/bin/sh -e

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
W3MMAN_MAN='man --no-hyphenation'

#echo "INFO: Looking for manpages in [$DEB]"
man=`dpkg-deb -c "$DEB" | egrep " \./usr/share/man/.*\.[0-9][a-zA-Z0-9\.\-]*\.gz$" | sed "s/^.*\.\//\.\//" | sed "s/ \-> /\->/"`
if [ -z "$man" ]; then
	#echo "INFO: No manpages: [$DIST] [$PKG]"
	# Touch the cache file so we don't look again until package updated
	touch $DESTDIR/.cache/$NAME
	# Exit immediately if this package does not contain manpages
	exit 0
fi
src_pkg=`dpkg -I "$DEB" | egrep "^ Package: |^ Source: " | tail -n1 | sed "s/^.*: //"`

#echo "INFO: Extracting manpages from [$DEB]"
TEMPDIR=`mktemp -d -t doc-XXXXXX`
dpkg-deb -x "$DEB" "$TEMPDIR"
for i in $man; do
	#echo "INFO: Considering entry [$i]"
	i=`echo "$i" | sed "s/^.*\.\///"`
	if echo "$i" | grep -qs "\->"; then
		SYMLINK=1
		symlink_src_html=`echo "$i" | sed "s/^.*\->//" | sed "s/\.gz$/\.html/"`
		i=`echo "$i" | sed "s/\->.*$//" `
		#echo "INFO: [$i] is a symbolic link"
	else
		SYMLINK=0
	fi
	manpage="$TEMPDIR/$i"
	i=`echo "$i" | sed "s/usr\/share\/man\///i" | sed "s/\.gz$//"`
	#echo "INFO: Considering manpage [$i]"
	if [ ! -s "$manpage" -o -z "$i" ] && [ "$SYMLINK" = "0" ]; then
		#echo "INFO: Skipping empty manpage [$manpage]"
		continue
	fi
	out="$DESTDIR"/"$i".html
	outgz=`dirname "$DESTDIRGZ"/"$i"`
	mkdir -p `dirname "$out"` "$outgz" > /dev/null || true
	if [ "$SYMLINK" = "1" ]; then
		ln -f -s "$symlink_src_html" "$out"
		echo "INFO: Created symlink [$out]"
	else
		if LN=`zcat "$manpage" | head -n1 | grep "^\.so "`; then
			LN=`echo "$LN" | sed 's/^\.so /\.\.\//' | sed 's/\/\.\.\//\//g' | sed 's/$/\.html/'`
			ln -f -s "$LN" "$out"
			echo "INFO: Created symlink [$out]"
                else
			#man "$manpage" 2>/dev/null | col -b > "$out".txt
			#man2html -r "$manpage" > "$out"
			w3mman -l "$manpage" | ./w3mman-to-html.pl "$NAME_AND_VER" "$DIST" "$src_pkg" > "$out"
			echo "INFO: Created manpage [$out]"
		fi
	fi
	mv -f "$manpage" "$outgz"
	touch "$DESTDIR/.cache/$NAME"
	if [ ! -s "$out" ]; then
		# Remove if it's an empty file
		rm -f "$out"
	fi
done
# In the case of freakish package permissions, fix them on rm failure.
rm -rf "$TEMPDIR" 2>/dev/null || ( chmod -R 700 "$TEMPDIR" && rm -rf "$TEMPDIR" ) || true
exit 0
