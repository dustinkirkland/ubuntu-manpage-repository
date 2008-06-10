#!/bin/sh

. ./config

for dist in $DISTROS; do
	mkdir -p $PUBLIC_HTML_DIR/manpages/$dist
	for repo in $REPOS; do
		DEBS=`cat $DEBDIR/dists/$dist/$repo/binary-$ARCH/Packages.gz | gunzip | grep "^Filename:.*\.deb$" | awk '{print $2}' | sort -u`
		for deb in $DEBS; do
			./fetch-man-pages.sh $PUBLIC_HTML_DIR/manpages/$dist/ "$DEBDIR/$deb" 
		done
	done
done

./make-sitemaps.sh
