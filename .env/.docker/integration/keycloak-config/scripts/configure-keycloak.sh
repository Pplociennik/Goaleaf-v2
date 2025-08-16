#!/bin/bash
set -e

echo "Waiting for Keycloak to be ready..."
until curl "http://integration-keycloak:9000/health/ready" | grep -q "UP"; do
    echo "Keycloak is unavailable - waiting..."
    sleep 10
done

echo "Keycloak is up - starting configuration"

/opt/keycloak/bin/kcadm.sh config credentials \
    --server http://integration-keycloak:8080 \
    --realm master \
    --user admin \
    --password admin

echo "Importing realm configuration..."
/opt/keycloak/bin/kcadm.sh create realms -f /config/realm-config.json

echo "Configuration completed successfully"