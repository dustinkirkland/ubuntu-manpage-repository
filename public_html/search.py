#!/usr/bin/python

import cgi
import os

html = "Content-Type: text/html\n\n" 

html += open("above.html").read()

descr = ["",								# 0
	"Executable programs or shell commands",			# 1
	"System calls (functions provided by the kernel)",		# 2
	"Library calls (functions within program libraries)",		# 3
	"Special files (usually found in /dev)",			# 4
	"File formats and conventions eg /etc/passwd",			# 5
	"Games",							# 6
	"Miscellaneous (including macro  packages  and  conventions)",	# 7
	"System administration commands (usually only for root)",	# 8
	"Kernel routines [Non standard]"]				# 9

get = cgi.FieldStorage()
if get.has_key("title"):
	t = get["title"].value
	versions = dict(dapper="6.06 LTS", feisty="7.04", gutsy="7.10", hardy="8.04 LTS", intrepid="8.10")
	distros = versions.keys()
	distros.sort()
	html += "<table><tr>"
	for d in distros:
		html += "<th>%s<br><small>%s</small></th>" % (d, versions[d])
	html += "<td>&nbsp;</td></tr>"
	for i in range(1,10):
		html += "<tr>"
		for d in distros:
			path = "manpages/%s/man%d/%s.html" % (d, i, t)
			if os.path.isfile(path):
				html += "<td><a href=%s>%s(%d)</a></td>" % (path, t, i)
			else:
				html += "<td align=center>.</td>"
		html += "<td>(%d) - <small>%s</small></td></tr>" % (i, descr[i])
	html += "</table>"

html += open("below.html").read()

print html
