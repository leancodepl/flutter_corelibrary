#!/usr/bin/env bash

export Logging__EnableDetailedInternalLogs=true
export Logging__MinimumLevel=Verbose
export Logging__SeqEndpoint='http://seq-svc.shared.svc.cluster.local'

export Kratos__PublicEndpoint='http://exampleapp-kratos-svc.kratos.svc.cluster.local'
export Kratos__AdminEndpoint='http://exampleapp-kratos-svc.kratos.svc.cluster.local:4434'
export Kratos__WebhookApiKey='Passw12#'

export PostgreSQL__ConnectionString='Host=postgresql-svc.shared.svc.cluster.local;Database=app;Username=app;Password=Passw12#'
export BlobStorage__ConnectionString='DefaultEndpointsProtocol=http;AccountName=blobstorage;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://blobstorage.blob.svc.cluster.local/;'

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$DIR/secrets.sh" ]]
then
    source "$DIR/secrets.sh"
fi
