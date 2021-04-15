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
# Copyright 2011-2012 OmniTI Computer Consulting, Inc.  All rights reserved.
# Copyright 2021 OmniOS Community Edition (OmniOSce) Association.
#
. ../../lib/functions.sh

PROG=autoconf
VER=2.71
PKG=developer/build/autoconf
SUMMARY="GNU $PROG"
DESC="$PROG - GNU autoconf utility"

RUN_DEPENDS_IPS="system/prerequisite/gnu developer/macro/gnu-m4"

set_arch 64
CONFIGURE_OPTS="--infodir=$PREFIX/share/info"
SKIP_LICENCES=GPL.EXCEPTION

init
download_source $PROG $PROG $VER
patch_source
prep_build
build
run_testsuite check
make_package
clean_up

# Vim hints
# vim:ts=4:sw=4:et:fdm=marker
