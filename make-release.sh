#!/usr/bin/env bash
export MIX_ENV=prod

mix deps.get
cd apps/web/assets/
npm set progress=false
npm i
./node_modules/brunch/bin/brunch b -p
cd ../
mix phx.digest
cd ../../
mix release --env=prod
# mix ecto.create # à activer pour créer la base de données sur la machine qui build la release
