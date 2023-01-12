#!/bin/sh
#https://askubuntu.com/questions/444082/how-to-check-if-1-and-2-are-null
#https://stackoverflow.com/questions/12900538
#https://www.ibm.com/docs/en/aix/7.2?topic=c-cmp-command
set -e

if [ -z $1 ] || [ -z $2 ]; then
    echo '$1 and $2 not found!'
    exit 1
fi

if cmp -s $1 $2; then
    echo "$1 and $2 are identical"
else
    echo "$1 and $2 are non-identical"
fi
