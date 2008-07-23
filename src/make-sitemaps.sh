#!/bin/sh

# Generate sitemaps per sitemaps.org for google.com

. ./config 

echo "INFO: Making sitemaps"

cd "$PUBLIC_HTML_DIR"
find manpages/ -type f -name "*.html" | xargs -i echo "<url><loc>$SITE/{}</loc></url>" | split -l 50000 - manpages/sitemap_

sitemaps=`ls manpages/sitemap_??`
for i in $sitemaps; do
	echo '<?xml version="1.0" encoding="UTF-8"?>' > $i.xml
	echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> $i.xml
	cat "$i" >> $i.xml
	echo '</urlset>' >> "$i.xml"
	rm -f "$i"
done
cd -
