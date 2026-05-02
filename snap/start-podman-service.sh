#!/bin/bash
set -e

# Ensure the socket directory exists in the user's snap common directory
SOCKET_DIR="$SNAP_USER_COMMON/socket"
mkdir -p "$SOCKET_DIR"
chmod 700 "$SOCKET_DIR"

# Run the podman API service, listening on the unix socket inside the exposed directory.
# The --time=0 flag keeps the service running indefinitely rather than timing out.
exec $SNAP/snap/podman-wrapper.sh system service --time=0 "unix://$SOCKET_DIR/podman.sock"
