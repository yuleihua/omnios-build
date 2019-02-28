#!/usr/bin/bash
#
# {{{ CDDL HEADER
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source. A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
# }}}
#
# Copyright 2018 OmniOS Community Edition (OmniOSce) Association.
#
. ../../../lib/functions.sh

PROG=openssl
VER=1.1.1b
VERHUMAN=$VER
PKG=library/security/openssl/preview
SUMMARY="Cryptography and SSL/TLS Toolkit (1.1.1 preview)"
DESC="A toolkit for Secure Sockets Layer and Transport Layer protocols "
DESC+="and general purpose cryptographic library"

RUN_DEPENDS_IPS+=" library/security/openssl"

OPENSSL_CONFIG_OPTS="shared threads zlib enable-ssl2 enable-ssl3 --api=1.0.0"
OPENSSL_CONFIG_32_OPTS=
OPENSSL_CONFIG_64_OPTS="enable-ec_nistp_64_gcc_128"

base_LDFLAGS="-shared -Wl,-z,text,-z,aslr,-z,ignore"

save_function make_prog _make_prog
make_prog() {
    MAKE_ARGS_WS="
        SHARED_LDFLAGS=\"$SHARED_LDFLAGS\"
        LIB_LDFLAGS=\"$SHARED_LDFLAGS\"
    "
    _make_prog
}

configure32() {
    SSLPLAT=solaris-x86-gcc
    logmsg -n "--- Configure (32-bit) $SSLPLAT"
    unset __CNF_CFLAGS
    logcmd ./Configure $SSLPLAT --prefix=$PREFIX \
        ${OPENSSL_CONFIG_OPTS} ${OPENSSL_CONFIG_32_OPTS} \
        || logerr "Failed to run configure"
    SHARED_LDFLAGS="$base_LDFLAGS"
}

configure64() {
    SSLPLAT=solaris64-x86_64-gcc
    logmsg -n "--- Configure (64-bit) $SSLPLAT"
    export __CNF_CFLAGS=-m64
    logcmd ./Configure $SSLPLAT --prefix=$PREFIX \
        ${OPENSSL_CONFIG_OPTS} ${OPENSSL_CONFIG_64_OPTS} \
        || logerr "Failed to run configure"
    SHARED_LDFLAGS="-m64 $base_LDFLAGS"
}

# Preserve the opensslconf.h file from each build since there will be
# differences due to the architecture.
# These are used to prepare the patch that is applied before packaging.
build() {
    [[ $BUILDARCH =~ ^(32|both)$ ]] && build32 && \
        logcmd cp $DESTDIR/usr/include/openssl/opensslconf.h{,.32}
    [[ $BUILDARCH =~ ^(64|both)$ ]] && build64 && \
        logcmd cp $DESTDIR/usr/include/openssl/opensslconf.h{,.64}
}

save_function make_package _make_package
make_package() {
    if echo $VER | egrep -s '[a-z]'; then
        NUMVER=${VER::$((${#VER} -1))}
        ALPHAVER=${VER:$((${#VER} -1))}
        VER=${NUMVER}.$(ord26 ${ALPHAVER})
    fi

    _make_package
}

# Move installed libs from /usr/lib to /lib
move_libs() {
    logmsg "Relocating libs from usr/lib to lib"
    logcmd mv $DESTDIR/usr/lib/{64,amd64} || logerr "mv"
    logcmd mkdir -p $DESTDIR/lib/amd64 || logerr "mkdir"
    logcmd mv $DESTDIR/usr/lib/lib* $DESTDIR/lib/ \
        || logerr "Failed to move libs (32-bit)"
    logcmd mv $DESTDIR/usr/lib/amd64/lib* $DESTDIR/lib/amd64/ \
        || logerr "Failed to move libs (64-bit)"
}

version_files() {
    typeset ver=$1
    pushd $DESTDIR >/dev/null || logerr "pushd version files"

    logcmd mv usr/include/openssl{,-$ver}
    for f in usr/bin/*; do
        logcmd mv $f{,-$ver} || logerr "mv bin"
    done
    [ -d usr/share/man ] && logcmd mv usr/share/man usr/ssl/man

    logcmd mkdir -p usr/ssl/lib usr/ssl/lib/amd64
    logcmd mv usr/lib/pkgconfig usr/ssl/lib/pkgconfig
    logcmd mv usr/lib/amd64/pkgconfig usr/ssl/lib/amd64/pkgconfig
    logcmd mv lib/lib*.a usr/ssl/lib
    logcmd mv lib/amd64/lib*.a usr/ssl/lib/amd64

    logcmd rm -f lib/lib{crypto,ssl}.so
    logcmd rm -f lib/amd64/lib{crypto,ssl}.so

    [ -d usr/ssl/certs ] && logcmd rm -rf usr/ssl/certs
    logcmd ln -s ../../etc/ssl/certs usr/ssl/certs
    # This is to satisfy the dangling symlink checker. It's excluded by the
    # local.mog
    mkdir -p etc/ssl/certs

    logcmd mv usr/ssl usr/ssl-$ver

    popd >/dev/null
}

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
(cd $DESTDIR; gpatch -p1 < $SRCDIR/$PATCHDIR/post/opensslconf.dualarch)
run_testsuite
move_libs
version_files ${VER%.*}
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
