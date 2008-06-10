#!/bin/sh

BASEDIR=/var/www/ubuntu
DEBDIR=/var/www/mirrors/ubuntu

#DISTROS="hardy gutsy feisty edgy dapper"
#REPOS="main restricted universe multiverse"
DISTROS="hardy gutsy feisty edgy dapper"
REPOS="main restricted universe multiverse"
ARCH="i386"

for dist in $DISTROS; do
	mkdir -p $BASEDIR/manpages/$dist
	for repo in $REPOS; do
		DEBS=`cat $DEBDIR/dists/$dist/$repo/binary-$ARCH/Packages.gz | gunzip | grep "^Filename:.*\.deb$" | awk '{print $2}' | sort -u`
		for deb in $DEBS; do
			$BASEDIR/fetch-man-pages.sh $BASEDIR/manpages/$dist/ "$DEBDIR/$deb" 
		done
	done
done

./make-sitemaps.sh
