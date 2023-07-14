#!/usr/bin/env bash
set -eo pipefail

PID=$(kubectl exec -n "$K8S_NS" --context "$K8S_CONTEXT" "$WORKLOAD" -- ps aux |
    awk "!/defunct/ && /$FILTER/ {print \$2 }")

if [[ "$PID" ]]; then
    echo "$PID|$FILTER||$PID";
else
    echo "|No running process with filter $FILTER"
fi;
