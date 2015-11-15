#! /bin/sh

cd ../..
echo $1
lime test neko -args level=$1
