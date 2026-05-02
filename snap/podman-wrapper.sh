#!/bin/bash

# Fallback for registries.conf
if [ ! -f "/etc/containers/registries.conf" ]; then
    export CONTAINERS_REGISTRIES_CONF="$SNAP/etc/registries.conf"
fi

# Fallback for policy.json
if [ ! -f "/etc/containers/policy.json" ]; then
    export CONTAINERS_POLICY_JSON="$SNAP/etc/policy.json"
fi

# Fallback for containers.conf
OVERRIDE_CONF="$SNAP_USER_COMMON/containers.conf.override"
cp "$SNAP/etc/containers.conf" "$OVERRIDE_CONF"

export CONTAINERS_CONF_OVERRIDE="$OVERRIDE_CONF"

exec "$SNAP/usr/bin/podman" "$@"
