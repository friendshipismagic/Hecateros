#!/usr/bin/env bash
set -e

git pull
./make-release.sh
_build/prod/rel/hekateros/bin/hekateros stop
_build/prod/rel/hekateros/bin/hekateros start
