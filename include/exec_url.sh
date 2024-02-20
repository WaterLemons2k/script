#!/bin/sh

curl --location --silent --output /tmp/script.sh "$URL" && bash /tmp/script.sh
rm /tmp/script.sh
