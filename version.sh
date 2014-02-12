#!/usr/bin/env bash
#
# hoster version definition.
version='1.6'
progname=`basename $0`

#  Version and help.
function version() {
    echo "$progname version $version"
}