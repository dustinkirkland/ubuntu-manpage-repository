#!/usr/bin/python

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

import cgi
import glob
import os
import re

# You may need to uncomment and edit this line in your environment
os.chdir("/srv/manpages.ubuntu.com/www")

html = "Content-Type: text/html\n\n"

html += open("../www/above1.html").read()
html += "Searching"
html += open("../www/above2.html").read()

get = cgi.FieldStorage()
p1 = re.compile( '^\.\.\/www' );
p2 = re.compile( '.*\/' );
p3 = re.compile( '\.html$' );
p4 = re.compile( '\.[0-9].*$' );
p5 = re.compile( ', $' );

# Google Custom Search Engine results (full text search)
google_cse_html = '''
<div id="cse-search-results"></div>
<script type="text/javascript">
  var googleSearchIframeName = "cse-search-results";
  var googleSearchFormName = "cse-search-box";
  var googleSearchFrameWidth = 500;
  var googleSearchDomain = "www.google.com";
  var googleSearchPath = "/cse";
  var googleSearchResizeIframe = false;
</script>
<script type="text/javascript" src="http://www.google.com/afsonline/show_afs_search.js"></script>
'''

# Title only (file name match search)
descr = ["",                            # 0
"Executable programs or shell commands",            # 1
"System calls (functions provided by the kernel)",      # 2
"Library calls (functions within program libraries)",       # 3
"Special files (usually found in /dev)",            # 4
"File formats and conventions eg /etc/passwd",          # 5
"Games",                            # 6
"Miscellaneous (including macro  packages  and  conventions)",  # 7
"System administration commands (usually only for root)",   # 8
"Kernel routines [Non standard]"]               # 9

t = ""
if get.has_key("q"):
    t = get["q"].value
x = 1
y = 9
extra = ""
# User might have specified the section
p = re.compile( '(.*)\.([1-9])(.*)$' );
n = p.search(t)
if n:
    t = n.group(1)
    x = int(n.group(2))
    y = x + 1
    extra = n.group(3)

p = re.compile( '[^\.a-zA-Z0-9\/_\:\+@-]' );
t = p.sub('', t)
title_html = "<script>document.forms[0].q.value='" + t + "';</script>"

if get.has_key("lr"):
    lr = get["lr"].value
    p = re.compile( '^lang_' );
    lr = p.sub('', lr)
    p = re.compile( '[^a-zA-Z-]' );
    lr = p.sub('', lr)
    p = re.compile( '[-]' );
    lr = p.sub('_', lr)
else:
    lr = "en"

versions = dict(hardy="8.04 LTS", lucid="10.04 LTS", maverick="10.10", natty="11.04", oneiric="11.10", precise="12.04")
distros = versions.keys()
distros.sort()
title_html += "<br><table border=2 cellpadding=5 cellspacing=0><tr><td><table cellspacing=0 cellpadding=5><tr>"
for d in distros:
    title_html += "<th bgcolor=#f0bcc1>%s<br><small>%s</small></th>" % (d, versions[d])
title_html += "<th bgcolor=#f0bcc1>Section Description</th></tr>"
matches = 0
for i in range(x,y):
    title_html += "<tr>"
    for d in distros:
        color = "lightgrey"
        path = "../www/manpages/%s/%s/man%d/%s.%d%s*.html" % (d, lr, i, t, i, extra)
        title_html += "<td align=center>"
        dot = "."
        for g in glob.glob(path):
            matches += 1
            dot = ""
            color = "black"
            href_path = p1.sub('', g)
            page = p2.sub('', g)
            page = p3.sub('', page)
            page = p4.sub('', page)
            title_html += '<a href="%s" style="text-decoration:none">%s(%d)</a>, ' % (href_path, page, i)
        title_html = p5.sub('', title_html)
        title_html += dot + "</td>"
    title_html += '<td><font color="%s">(%d) - <small>%s</small></td></tr>' % (color, i, descr[i])
title_html += "</table></td></tr></table><br>"
if (matches > 0):
    if get.has_key("titles") and get["titles"].value == "404":
        # If we were sent here by a 404-not-found, and we have at least one match,
        # redirect the user to the last page in our list
        html += "<script>location.replace('" + href_path + "');</script>"
    else:
        # Otherwise, a normal title search, display the title table
        html += title_html
else:
    # But if we do not find any matching titles, do a full text search
    html += "<strong>No matching titles found - Full text search results below</strong>"

html += "<hr />" + google_cse_html
html += open("../www/below.html").read()
print html
