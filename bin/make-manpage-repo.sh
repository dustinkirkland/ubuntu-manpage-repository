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

# Establish some locking, to keep multiple updates from running
LOCK="$PUBLIC_HTML_DIR/manpages/UPDATE_IN_PROGRESS"
if [ -e "$LOCK" ]; then
	echo "ERROR: Update is currently running"
	echo "Lock: $LOCK"
	cat "$LOCK"
	exit 1
fi
trap "rm -f $LOCK 2>/dev/null || true" EXIT HUP INT QUIT TERM
date > $LOCK

FORCE="$1"

pkg_updated() {
	if [ "$FORCE" = "-f" ]; then
		return 0
	fi
	deb="$1"
	#echo "INFO: Looking at package [$deb]"
	name=`basename "$deb" | awk -F_ '{print $1}'`
	cache_modtime=`stat -c %Y "$PUBLIC_HTML_DIR/manpages/$dist/.cache/$name" 2>/dev/null || echo "0"`
	deb_modtime=`stat -c %Y "$DEBDIR/$deb"`
	if [ "$cache_modtime" -ge "$deb_modtime" ]; then
	        #echo "INFO: Skipping non-updated package [$DEBDIR/$deb]"
		return 1
	else
		return 0
	fi
}

handle_deb() {
	dist="$1"
	deb="$2"
	pkg_updated "$deb" && ./fetch-man-pages.sh "$dist" "$deb" || true
}

link_en_locale() {
	dist="$1"
	for i in `seq 1 9`; do
		dir="$PUBLIC_HTML_DIR/manpages/$dist/en/man$i"
		if [ -L "$dir" ]; then
			# link exists: we're good
			continue
		elif [ -d "$dir" ]; then
			# dir exists: mv, ln, restore
			mv -f "$dir" "$dir.bak"
			ln -s "../man$i" "$dir"
			mv -f "$dir.bak"/* "$dir"
			rmdir "$dir.bak"
		else
			# link does not exist: establish the link
			ln -s "../man$i" "$dir"
		fi
	done
	return 0
}


for dist in $DISTROS; do
	export dist
	mkdir -p "$PUBLIC_HTML_DIR/manpages/$dist/.cache" "$PUBLIC_HTML_DIR/manpages.gz/$dist" || true
	link_en_locale "$dist"
	for repo in $REPOS; do
		zcat "$DEBDIR/dists/$dist/$repo/binary-$ARCH/Packages.gz" | grep "^Filename:.*\.deb$" | awk '{print $2}' | sort -u | \
			while read deb; do
				handle_deb "$dist" "$deb"
			done
	done
done

./make-sitemaps.sh
