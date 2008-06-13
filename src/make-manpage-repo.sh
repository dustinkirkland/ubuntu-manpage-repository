#!/bin/sh

. ./config

pkg_updated() {
	#echo "INFO: Looking at package [$deb]"
	name=`basename "$deb" | awk -F_ '{print $1}'`
	cache_modtime=`(ls -log --time-style=+%s $PUBLIC_HTML_DIR/manpages/$dist/.cache/$name 2>/dev/null || echo "0 0 0 0") | awk '{print $4}'`
	deb_modtime=`ls -log --time-style=+%s "$DEBDIR/$deb" | awk '{print $4}'`
	if [ "$cache_modtime" -ge "$deb_modtime" ]; then
	        #echo "INFO: Skipping non-updated package [$DEBDIR/$deb]"
	        /bin/false
	else
		/bin/true
	fi
}


for dist in $DISTROS; do
	mkdir -p $PUBLIC_HTML_DIR/manpages/$dist/.cache
	for repo in $REPOS; do
		DEBS=`cat $DEBDIR/dists/$dist/$repo/binary-$ARCH/Packages.gz | gunzip | grep "^Filename:.*\.deb$" | awk '{print $2}' | sort -u`
		for deb in $DEBS; do
			pkg_updated && ./fetch-man-pages.sh $dist $deb
		done
	done
done

#./make-sitemaps.sh
