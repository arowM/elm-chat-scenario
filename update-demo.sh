#! /bin/bash

set -ue

cd sample/simple/
npm i
npm run build
rm -rf ../../docs/simple/
mv dist ../../docs/simple
