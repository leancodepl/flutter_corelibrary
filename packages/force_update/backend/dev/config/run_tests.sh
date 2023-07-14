#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/integration_tests.sh"

export XUNIT_EXECUTION_MAXPARALLELTESTS=$(nproc)

if [[ "$DISABLE_SLEEP" == "true" ]]; then
    if [[ -z "$TESTS_FQN" ]]; then
        exec dotnet test ~/bin/ExampleApp.IntegrationTests.dll
    else
        exec dotnet test --filter "FullyQualifiedName~$TESTS_FQN" ~/bin/ExampleApp.IntegrationTests.dll
    fi
else
    if [[ -z "$TESTS_FQN" ]]; then
        dotnet test ~/bin/ExampleApp.IntegrationTests.dll
    else
        dotnet test --filter "FullyQualifiedName~$TESTS_FQN" ~/bin/ExampleApp.IntegrationTests.dll
    fi
    sleep 3600
fi
