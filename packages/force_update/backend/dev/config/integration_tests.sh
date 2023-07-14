#!/usr/bin/env bash

export Kratos__PublicEndpoint='http://localhost'
export Kratos__AdminEndpoint='http://localhost'
export Kratos__WebhookApiKey='Passw12#'

export PostgreSQL__ConnectionStringBase='Host=postgresql-svc.shared.svc.cluster.local;Username=postgres;Password=Passw12#'
export BlobStorage__ConnectionString='DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://storage.local.lncd.pl:10000/devstoreaccount1;'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$DIR/integration_tests_secrets.sh" ]]
then
    source "$DIR/integration_tests_secrets.sh"
fi
