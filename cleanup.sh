#!/usr/bin/env bash
# cleanup.sh
# Deletes the resource groups created by the other scripts, which removes everything
# inside them (the VM, its disk and network, the SQL server and the database).
# This cannot be undone, so the script asks you to confirm first.
#
# Usage:
#   ./cleanup.sh
#   RESOURCE_GROUPS="myResourceGroup mySqlResourceGroup" ./cleanup.sh

set -euo pipefail

RESOURCE_GROUPS="${RESOURCE_GROUPS:-myResourceGroup mySqlResourceGroup}"

echo "This will permanently delete these resource groups and everything in them:"
for rg in $RESOURCE_GROUPS; do
    echo "  - $rg"
done
read -r -p "Type DELETE to continue: " answer

if [[ "$answer" != "DELETE" ]]; then
    echo "Cancelled. Nothing was deleted."
    exit 0
fi

for rg in $RESOURCE_GROUPS; do
    if [[ "$(az group exists --name "$rg")" == "true" ]]; then
        echo "Deleting $rg..."
        az group delete --name "$rg" --yes --no-wait
    else
        echo "$rg does not exist, skipping."
    fi
done

echo "Deletion started in the background. Check progress with: az group list --output table"
