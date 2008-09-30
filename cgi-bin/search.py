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
import os
import re

# You may need to uncomment and edit this line in your environment
os.chdir("/var/www/ubuntu-manpage-repository/cgi-bin")

html = "Content-Type: text/html\n\n" 

html += open("../www/above1.html").read()
html += "Searching"
html += open("../www/above2.html").read()

get = cgi.FieldStorage()

if get.has_key("text"):
	# Google Custom Search Engine results (full text search)
	html += '''
<div id="cse-search-results"></div>
<script type="text/javascript">
  var googleSearchIframeName = "cse-search-results";
  var googleSearchFormName = "cse-search-box";
  var googleSearchFrameWidth = 600;
  var googleSearchDomain = "www.google.com";
  var googleSearchPath = "/cse";
  var googleSearchResizeIframe = false;
</script>
<script type="text/javascript" src="http://www.google.com/afsonline/show_afs_search.js"></script>
'''
else:
	# Title only (file name match search)
	descr = ["",							# 0
	"Executable programs or shell commands",			# 1
	"System calls (functions provided by the kernel)",		# 2
	"Library calls (functions within program libraries)",		# 3
	"Special files (usually found in /dev)",			# 4
	"File formats and conventions eg /etc/passwd",			# 5
	"Games",							# 6
	"Miscellaneous (including macro  packages  and  conventions)",	# 7
	"System administration commands (usually only for root)",	# 8
	"Kernel routines [Non standard]"]				# 9

	t = ""
	if get.has_key("title"):
		t = get["title"].value
	elif get.has_key("q"):
		t = get["q"].value
	if t != "":
		html += "<script>document.forms[0].q.value='" + t + "';</script>"
		p = re.compile( '[^\.a-zA-Z0-9\/_\:\+@-]' );
		t = p.sub('', t)

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

		versions = dict(dapper="6.06 LTS", feisty="7.04", gutsy="7.10", hardy="8.04 LTS", intrepid="8.10")
		distros = versions.keys()
		distros.sort()
		html += "<br><table border=2 cellpadding=5 cellspacing=0><tr><td><table cellspacing=0 cellpadding=5><tr>"
		for d in distros:
			html += "<th bgcolor=#EAD9B4>%s<br><small>%s</small></th>" % (d, versions[d])
		html += "<th bgcolor=#EAD9B4>Section Description</th></tr>"
		for i in range(1,10):
			html += "<tr>"
			for d in distros:
				color = "lightgrey"
				path = "../www/manpages/%s/%s/man%d/%s.html" % (d, lr, i, t)
				href_path = "/manpages/%s/%s/man%d/%s.html" % (d, lr, i, t)
				if os.path.isfile(path):
					color = "black"
					html += '<td><a href="%s" style="text-decoration:none">%s(%d)</a></td>' % (href_path, t, i)
				else:
					html += "<td align=center>.</td>"
			html += '<td><font color="%s">(%d) - <small>%s</small></td></tr>' % (color, i, descr[i])
		html += "</table></td></tr></table><br>"


html += open("../www/below.html").read()
print html
