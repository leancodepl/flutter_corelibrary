#!/usr/bin/env bash

source ~/config/config.sh

cd ~/bin

if [[ -v SEED ]]
then
    echo "Seeding"
    dotnet ExampleApp.Migrations.dll seed
else
    echo "Migrating"
    dotnet ExampleApp.Migrations.dll migrate
fi
