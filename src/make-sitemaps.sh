#!/bin/sh

. ./config 

cd $PUBLIC_HTML_DIR
find manpages/ -type f -name "*.html" | xargs -i echo "<url><loc>$SITE/{}</loc></url>" | split -l 50000 - manpages/sitemap_

echo "INFO: Making sitemaps"
sitemaps=`ls manpages/sitemap_??`
for i in $sitemaps; do
	echo '<?xml version="1.0" encoding="UTF-8"?>' > $i.xml
	echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> $i.xml
	cat $i >> $i.xml
	echo '</urlset>' >> $i.xml
	rm -f $i
done
cd -
