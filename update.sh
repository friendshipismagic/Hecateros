#!/usr/bin/env bash
set -e

git pull
./make-release.sh
_build/prod/rel/hecateros/bin/hecateros stop
_build/prod/rel/hecateros/bin/hecateros start
