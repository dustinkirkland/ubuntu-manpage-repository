#!/bin/sh

. ./config

FORCE="$1"

pkg_updated() {
	if [ "$FORCE" = "-f" ]; then
		return 0
	fi
	deb="$1"
	#echo "INFO: Looking at package [$deb]"
	name=`basename "$deb" | awk -F_ '{print $1}'`
	cache_modtime=`(ls -log --time-style=+%s "$PUBLIC_HTML_DIR/manpages/$dist/.cache/$name" 2>/dev/null || echo "0 0 0 0") | awk '{print $4}'`
	deb_modtime=`ls -log --time-style=+%s "$DEBDIR/$deb" | awk '{print $4}'`
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
	pkg_updated "$deb" && ./fetch-man-pages.sh "$dist" "$deb"
}


for dist in $DISTROS; do
	export dist
	mkdir -p "$PUBLIC_HTML_DIR/manpages/$dist/.cache $PUBLIC_HTML_DIR/manpages.gz/$dist"
	for repo in $REPOS; do
		zcat "$DEBDIR/dists/$dist/$repo/binary-$ARCH/Packages.gz" | grep "^Filename:.*\.deb$" | awk '{print $2}' | sort -u | \
			while read deb; do
				handle_deb "$dist" "$deb"
			done
	done
done

#./make-sitemaps.sh
