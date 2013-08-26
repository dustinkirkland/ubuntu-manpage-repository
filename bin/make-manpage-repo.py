#!/usr/bin/python

###############################################################################
# This is the Ubuntu manpage repository generator and interface.
#
# Copyright (C) 2013 Dustin Kirkland <dustin.kirkland@gmail.com>
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

import argparse
import apt.debfile
import errno
import gzip
import json
import logging
import os
import pprint
import re
import requests
import subprocess
import sys
import tempfile

CONFIG = json.loads(open("config.json").read())
LOCKFILE = "%s/manpages/UPDATE_IN_PROGRESS" % CONFIG["PUBLIC_HTML_DIR"]
TEMPFILE = ""
TEMPDIR = ""
PACKAGES = ""
logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s', level=logging.INFO)


def cleanup():
	for i in [TEMPFILE, LOCKFILE, PACKAGES]:
		if os.path.exists(i):
			os.unlink(i)


def error(msg):
	logging.error(msg)
	cleanup()
	os._exit(1)


def mkdir_p(path):
	try:
		os.makedirs(path)
	except OSError as exc:
		if exc.errno == errno.EEXIST and os.path.isdir(path):
			pass
		else:
			raise


def handle_deb(dist, deb, md5, forced):
	logging.info("Examining package [%s]" % deb)
	if forced or package_updated(dist, deb, md5):
		logging.info("  Downloading package [%s]" % deb)
		if fetch_manpages(dist, deb, md5):
			return True
		else:
			return False
	else:
		logging.info("  Skipping unchanged package [%s]" % deb)
		return True


def package_updated(dist, deb, md5):
	cache = "%s/manpages/%s/.cache/%s" % (CONFIG["PUBLIC_HTML_DIR"], dist, deb)
	if os.path.exists(cache) and open(cache).read() == md5:
		return False
	else:
		return True


def fetch_manpages(dist, deb, md5):
	url = "%s/%s" % (CONFIG["WEBARCHIVE"], deb)
	logging.info("    Fetching url [%s]" % url)
	if download_file(url, TEMPFILE):
		logging.info("    Looking for manpages in [%s]" % deb)
		manpages = []
		for f in apt.debfile.DebPackage(TEMPFILE).filelist:
			if re.search("^usr/share/man/.*\.gz$", f):
				manpages.append(f)
		if manpages:
			logging.info("    Extracting manpages from [%s]" % deb)
			proc = subprocess.Popen(['dpkg', '-x', TEMPFILE, TEMPDIR], stdout=subprocess.PIPE)
			out, _ = proc.communicate(None)
			for m in manpages:
				logging.info("      Considering manpage [%s]" % m)
		else:
			logging.info("    No manpages in [%s]" % deb)
			cache_file = "%s/manpages/%s/.cache/%s" % (CONFIG["PUBLIC_HTML_DIR"], dist, deb)
			mkdir_p(os.path.dirname(cache_file))
			with open(cache_file, 'w') as f:
				f.write(md5)
			return True
	return False


def link_en_locale(dist):
	mkdir_p("%s/manpages/%s/en" % (CONFIG["PUBLIC_HTML_DIR"], dist))
	for i in range(1, 10):
		for j in ["manpages", "manpages.gz"]:
			mkdir_p("%s/%s/%s/en" % (CONFIG["PUBLIC_HTML_DIR"], j, dist))
			d = "%s/%s/%s/en/man%d" % (CONFIG["PUBLIC_HTML_DIR"], j, dist, i)
			if os.path.islink(d):
				continue
			elif os.path.isdir(d):
				d_bak = "%s.bak" % d
				os.rename(d, d_bak)
				os.symlink("../man%d" % i, d)
				for k in os.listdir(d_bak):
					os.rename("%s/%s" % (d_bak, k), d)
				os.rmdir(d_bak)
			else:
				os.symlink("../man%d" % i, d)
	return True


def download_file(url, output_file):
	response = requests.get(url)
	if response.status_code == 200:
		with open(output_file, "w") as f:
			for chunk in response.iter_content():
				f.write(chunk)
		return True
	else:
		return False


if __name__ == '__main__':
#	try:
	if True:
		# Establish some locking, to keep multiple updates from running
		mkdir_p("%s/manpages" % CONFIG["PUBLIC_HTML_DIR"])
		if os.path.exists(LOCKFILE):
			error("Update is currently running, lock [%s]" % LOCKFILE)
		fd, TEMPFILE = tempfile.mkstemp(prefix='manpages-pkg-', suffix='.deb')
		TEMPDIR = tempfile.mkdtemp(prefix='manpages-dir-')
		fd, PACKAGES = tempfile.mkstemp(prefix='manpages-packages-', suffix='.gz')
		f = open(LOCKFILE, "w")
		f.write("")
		f.close
		parser = argparse.ArgumentParser(description='Create a repository of manpages')
		parser.add_argument('-f', '--force', help='Ignore caching and force a full repository creation', action="store_true", default=False)
		parser.options = parser.parse_args()
		for d in CONFIG["DISTROS"]:
			mkdir_p("%s/manpages/%s/.cache" % (CONFIG["PUBLIC_HTML_DIR"], d))
			mkdir_p("%s/manpages.gz/%s" % (CONFIG["PUBLIC_HTML_DIR"], d))
			link_en_locale(d)
			for r in CONFIG["REPOS"]:
				url = "%s/dists/%s/%s/binary-i386/Packages.gz" % (CONFIG["WEBARCHIVE"], d, r)
				logging.info("Fetching package list [%s]" % url)
				download_file(url, PACKAGES)
				deb = False
				md5 = False
				for line in gzip.open(PACKAGES, "rb").read().splitlines():
					if line.startswith("Filename:") and line.endswith(".deb"):
						deb = line.split()[1]
					elif line.startswith("MD5sum:"):
						md5 = line.split()[1]
					if deb and md5:
						handle_deb(d, deb, md5, parser.options.force)
						deb = False
						md5 = False
#	except (Exception,):
	else:
		e = sys.exc_info()[1]
		error("%s" % (str(e)))
	cleanup()
	os._exit(0)
