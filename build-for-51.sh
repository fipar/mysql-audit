#!/bin/bash
# this builds the mysql-audit plugin for a 5.1 Percona Server tree

# we need to know the mysql version in order to build
# this is customized for PS *only*, version should be a string like 5.1.57-12.8
[ $# -eq 0 ] && {
	echo "usage: $0 <mysql-version>">&2
	exit 1
}

VERSION="$1"
VERSION_NOREL=$(echo $VERSION|awk -F'-' '{print $1}')
URL=http://www.percona.com/redir/downloads/Percona-Server-5.1/Percona-Server-${VERSION}/source/Percona-Server-${VERSION_NOREL}.tar.gz
FILE=$(basename $URL)

# create a work directorio if needed
[ -d workspace ] || mkdir workspace
pushd workspace

# get the source if not present
[ -f $FILE -o -d Percona-Server-${VERSION_NOREL} ] || {
	wget $URL
	tar xzvf $FILE && rm -f $FILE
}

# build the libs
cd Percona-Server-*
CXX=gcc ./configure 
cd include
make
popd

# build the plugin
chmod +x bootstrap.sh 
./bootstrap.sh
CXX='gcc -static-libgcc' CC='gcc -static-libgcc' ./configure --with-mysql=./workspace/Percona-Server-${VERSION_NOREL}
make
echo "if all went good, the next line should tell you were the lib is"
find . -name '*so'
