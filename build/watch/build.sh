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

# Copyright 2020 OmniOS Community Edition (OmniOSce) Association.

. ../../lib/functions.sh

PROG=watch
VER=3.3.16
PKG=system/watch
SUMMARY="execute a program repeatedly, displaying output fullscreen"
DESC="GNU watch - $SUMMARY"

set_arch 64
set_builddir procps-v$VER

export CFLAGS+=" -I/usr/include/ncurses"
export NCURSES_CFLAGS=-I/usr/include/ncurses
export NCURSES_LIBS="-lncurses"
CONFIGURE_OPTS="
    --disable-dependency-tracking
"

MAKE_ARGS=watch

make_install() {
    pushd $TMPDIR/$BUILDDIR > /dev/null
    logcmd mkdir -p $DESTDIR/usr/bin $DESTDIR/usr/share/man/man1
    logcmd cp watch $DESTDIR/usr/bin/ || logerr "cp watch"
    logcmd cp watch.1 $DESTDIR/usr/share/man/man1/ || logerr "cp watch.1"
    popd > /dev/null
}

init
download_source procps-ng procps v$VER
patch_source
run_autoreconf -fi
prep_build
build
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
