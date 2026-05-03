# Podman Snap Smoketests

This directory contains a suite of high-level functional smoketests designed to verify the core capabilities of Podman, specifically tailored for validating its behavior within a snap confinement environment.

## Overview

The `run.sh` script is an automated bash script that rapidly fires through a broad selection of Podman commands to ensure they exit cleanly and perform their expected functions.

### Areas Covered:
1. **System & Info**: Base daemon health (`info`, `version`).
2. **Image Management**: Registry pulls, local tagging, image building (`build`).
3. **Container Lifecycle**: Detached runs, interactive logs, process execution (`exec`), and lifecycle states (`stop`, `rm`).
4. **Volumes**: Local named volumes and host-path bind mounting (validating rootless UID mapping and snap interface permissions).
5. **Networking**: Custom bridge network creation via `netavark`, and port forwarding via `pasta`.
6. **Pods**: Pod creation, infra container (`catatonit`) execution, and shared namespaces.
7. **Secrets**: Native secret generation and container injection.
8. **Kubernetes**: Generating and playing Kubernetes YAML definitions natively.

## Usage

Simply execute the test suite:
```bash
./run.sh
```

The script will automatically clean up after itself. If any test fails, it will print the error output and exit with a non-zero status.
