#!/usr/bin/python

import cgi
import os

html = "Content-Type: text/html\n\n" 

f = open("above.html")
html += f.read()
f.close

get = cgi.FieldStorage()
if get.has_key("title"):
	t = get["title"].value
	distros = ["intrepid", "hardy", "gutsy", "feisty", "dapper"]
	html += "<table><tr>"
	for d in distros:
		html += "<th>" + d + "</th>"
	html += "</tr>"
	for i in range(1,9):
		html += "<tr>"
		for d in distros:
			path = "manpages/%s/man%d/%s.html" % (d, i, t)
			if os.path.isfile(path):
				html += "<td><a href=%s>%s(%d)</a></td>" % (path, t, i)
			else:
				html += "<td align=center>.</td>"
		html += "</tr>"
	html += "</table>"


f = open("below.html")
html += f.read()
f.close

print html
