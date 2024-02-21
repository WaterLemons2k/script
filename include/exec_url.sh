#!/bin/sh

TEMP_SCRIPT="/tmp/$(tr </dev/urandom -dc _a-z | head -c 10).sh"
trap 'rm -f $TEMP_SCRIPT' EXIT

curl --location --silent --output "$TEMP_SCRIPT" "$URL" && bash "$TEMP_SCRIPT"
