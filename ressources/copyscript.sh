#!/bin/bash
##
mkdir -p output/img
mkdir -p output/fonts

## app files
cp sources/ressources/fonts/* output/fonts/
cp sources/ressources/img/* output/img/
cp sources/ressources/svg/* output/img/
cp sources/ressources/favicon/* output/

echo 0
