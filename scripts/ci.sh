#!/bin/sh

export DATABASE_URL=$DATABASE_URL.$BUILDKITE_BUILD_NUMBER

cd ..

if [ ! -d cog ]; then
  echo "Setting up cog..."

  git clone git@github.com:operable/cog.git
  cd cog
else
  echo "Making sure cog is up-to-date..."

  cd cog
  git pull origin master
fi

mix do deps.get, ecto.create, ecto.migrate

echo "Starting cog..."

elixir --detached -S mix phoenix.server

while ! nc -z localhost 4000; do
  sleep 0.1
done

cd ../cogctl

set -e
test_status=0
(mix deps.get && mix compile --warnings-as-errors && mix test) || test_status=$?
set +e

ps x | grep elixir | grep -v grep | cut -d ' ' -f 1 | xargs kill

exit $test_status
