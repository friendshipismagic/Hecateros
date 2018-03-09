#!/usr/bin/env bash
set -e

export MIX_ENV=prod
export HOSTNAME=hecateros.kratom.random.sh
export PORT=4000

wget https://github.com/friendshipismagic/Hecateros/archive/master.zip -O master.zip

unzip -qu master.zip
cd Hecateros-master
mix deps.get
cd apps/web/assets/
npm set progress=false
npm i
./node_modules/brunch/bin/brunch b -p
cd ../
mix phx.digest
cd ../../
mix release --env=prod
