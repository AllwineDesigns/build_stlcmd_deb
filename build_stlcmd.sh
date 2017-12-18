#!/bin/sh

cd /tmp
git clone https://github.com/AllwineDesigns/stl_cmd.git
cd stl_cmd
git archive --format tar.gz --prefix stlcmd-1.0/ -o ../stlcmd-1.0.tar.gz master
cd ..
mv stlcmd-1.0.tar.gz stlcmd_1.0.orig.tar.gz
tar xf stlcmd_1.0.orig.tar.gz
cd stlcmd-1.0
mkdir -p debian/source

# The output of the following cat command was originally created with manual changes after running
# dch --create v 1.0-1 --package stlcmd

cat <<EOF > debian/changelog 
stlcmd (1.0-1) UNRELEASED; urgency=low

  * Initial release. (Closes: #884310)

 -- John Allwine <john@allwinedesigns.com>  Sun, 17 Dec 2017 20:57:31 +0000

EOF

echo 10 > debian/compat

cat <<EOF > debian/control
Source: stlcmd
Maintainer: John Allwine <john@allwinedesigns.com>
Section: misc
Priority: optional
Standards-Version: 3.9.7
Build-Depends: debhelper (>= 9)

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
Copyright Allwine Designs, LLC 2017
EOF

cat <<EOF > debian/rules
#!/usr/bin/make -f
%:
\tdh \$@
DEB_HOST_GNU_TYPE   ?= \$(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)

ifeq (\$(origin CC),default)
CC := \$(DEB_HOST_GNU_TYPE)-g++
endif

override_dh_auto_build:
\t\$(MAKE) CC=\$(CC)

override_dh_auto_install:
\t\$(MAKE) DESTDIR=\$\$(pwd)/debian/stlcmd prefix=/usr install
EOF
sed -i 's/\\t/\t/g' debian/rules
chmod +x debian/rules

cat <<EOF > debian/source/format
3.0 (quilt)
EOF

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
