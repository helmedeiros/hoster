#!/usr/bin/env bash
#
# hoster version definition.
#Altering to read from hoster.version
#version='1.7.0'
version=$(cat $(dirname $0)/hoster.version)
progname=`basename $0`

#  Version and help.
function version() {
    echo "$progname version $version"
}
