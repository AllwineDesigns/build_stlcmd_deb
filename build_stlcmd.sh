#!/bin/sh

cd /tmp
#git clone https://github.com/AllwineDesigns/stl_cmd.git
#cd stl_cmd
#git archive --format tar.gz --prefix stlcmd-1.0/ -o ../stlcmd-1.0.tar.gz master
#cd ..
#mv stlcmd-1.0.tar.gz stlcmd_1.0.orig.tar.gz

curl -L -o stlcmd_1.1.orig.tar.gz https://github.com/AllwineDesigns/stl_cmd/archive/v1.1.tar.gz
curl -L -o stlcmd_1.1.orig.tar.gz.asc https://github.com/AllwineDesigns/stl_cmd/releases/download/v1.1/stl_cmd-1.1.tar.gz.asc

tar xf stlcmd_1.1.orig.tar.gz
mv stl_cmd-1.1 stlcmd-1.1
cd stlcmd-1.1
mkdir -p debian/source
mkdir -p debian/upstream

# The output of the following cat command was originally created with manual changes after running
# dch --create v 1.1-1 --package stlcmd

cat <<EOF > debian/changelog 
stlcmd (1.1-1) unstable; urgency=medium

  * Fixed Makefile to properly install stl_boolean. (Closes: #885792)

 -- John Allwine <john@allwinedesigns.com>  Sat, 30 Dec 2017 04:13:36 +0000

stlcmd (1.0-1) unstable; urgency=low

  * Initial release. (Closes: #884310)

 -- John Allwine <john@allwinedesigns.com>  Sun, 17 Dec 2017 20:57:31 +0000

EOF

echo 10 > debian/compat

cat <<EOF > debian/control
Source: stlcmd
Maintainer: John Allwine <john@allwinedesigns.com>
Homepage: https://www.github.com/AllwineDesigns/stl_cmd
Section: misc
Priority: optional
Standards-Version: 3.9.8
Build-Depends: debhelper (>= 10), help2man

Package: stlcmd
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Suite of commands for generating, inspecting and manipulating STL files
 stl_cmd is a suite of command line tools for generating, inspecting and
 manipulating STL files which are often used in 3D printing. The goal of this 
 project is to be a resource for teaching terminal usage and some basic 
 programming concepts in the 3D printing space. Imagine an assignment which 
 involves building a brick wall. Students would need to use a combination of 
 stl_cube, stl_transform and stl_merge. The commands could be combined in a 
 bash or <insert favorite scripting language> script with for and while 
 loops, could accept input and use conditionals to affect the attributes of 
 the wall.
EOF

cat <<EOF > debian/copyright
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: stl_cmd
Upstream-Contact: John Allwine <john@allwinedesigns.com>
Source: https://www.github.com/AllwineDesigns/stl_cmd
License: GPL-3+
Copyright: 2017 Allwine Designs, LLC

Files: *
Copyright: 2017 Allwine Designs, LLC
License: GPL-3+

Files: src/csgjs/*
Copyright: 2011 Evan Wallace (http://madebyevan.com/)
           2012 Joost Nieuwenhuijse (joost@newhouse.nl)
           2017 @jscad
           2017 Allwine Designs, LLC
License: MIT

License: GPL-3+
  This package is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
  .
  This package is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  .
  You should have received a copy of the GNU General Public License
  along with this package; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
  .
  On Debian systems, the complete text of the GNU General
  Public License can be found in \`/usr/share/common-licenses/GPL-3'.

License: MIT
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  .
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  .
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
EOF

cat <<EOF > debian/rules
#!/usr/bin/make -f
%:
\tdh \$@

DEB_HOST_GNU_TYPE   ?= \$(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)

ifeq (\$(origin CC),default)
CC := \$(DEB_HOST_GNU_TYPE)-g++
endif

export DEB_BUILD_MAINT_OPTIONS = hardening=+all

override_dh_auto_build:
\t\$(MAKE) CC=\$(CC)
\t\$(MAKE) docs

override_dh_auto_install:
\t\$(MAKE) DESTDIR=\$\$(pwd)/debian/stlcmd prefix=/usr install
\t\$(MAKE) DESTDIR=\$\$(pwd)/debian/stlcmd prefix=/usr installDocs
\tmkdir -p \$\$(pwd)/debian/stlcmd/usr/share/doc/stlcmd
\tgzip -n -c -9 CHANGES > \$\$(pwd)/debian/stlcmd/usr/share/doc/stlcmd/changelog.gz
EOF
sed -i 's/\\t/\t/g' debian/rules
chmod +x debian/rules

cat <<EOF > debian/source/format
3.0 (quilt)
EOF

cat <<EOF > debian/watch
version=4
opts=filenamemangle=s/.+\/v(\d\S+)\.tar\.gz/stlcmd-\$1\.tar\.gz/,\
pgpsigurlmangle=s/archive\/v(\d\S+)\.tar\.gz/releases\/download\/v\$1\/stl_cmd-\$1.tar.gz.asc/ \
https://github.com/AllwineDesigns/stl_cmd/releases .*/v?(\d\S+)\.tar\.gz
EOF

cp /tmp/signing-key.asc debian/upstream/signing-key.asc

debuild -us -uc

cat <<EOF > ~/.dput.cf
[mentors]
fqdn = mentors.debian.net
incoming = /upload
method = http
allow_unsigned_uploads = 0
progress_indicator = 2
# Allow uploads for UNRELEASED packages
allowed_distributions = .*
EOF
