#!/bin/sh
set -e

rm -rf dist
mkdir dist
cp src/index.html dist/
cp res/favicon.png dist/
cp CNAME dist/
elm make src/Main.elm --yes --output dist/main.js
echo "Done!"
