#!/bin/bash

# Podman High-Level Smoketest Suite
# This script executes a comprehensive set of tests to verify Podman functionality.

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

test_passed=0
test_failed=0

run_test() {
    local test_name="$1"
    shift
    echo -n "Running $test_name... "
    if "$@" > /tmp/smoketest.log 2>&1; then
        echo -e "${GREEN}OK${NC}"
        test_passed=$((test_passed+1))
    else
        echo -e "${RED}FAILED${NC}"
        echo "Output:"
        cat /tmp/smoketest.log
        test_failed=$((test_failed+1))
    fi
}

echo "Starting Podman High-Level Smoketests..."

# Cleanup before starting
podman rm -f smoke-test net-test pod-cont kube-test 2>/dev/null || true
podman pod rm -f smoke-pod 2>/dev/null || true
podman network rm smoke-net 2>/dev/null || true
podman volume rm smoke-vol 2>/dev/null || true
podman secret rm smoke-secret 2>/dev/null || true

# 1. System & Info
run_test "podman info" podman info
run_test "podman version" podman version

# 2. Image Management
run_test "podman pull alpine" podman pull docker.io/library/alpine:latest
run_test "podman inspect image" podman inspect docker.io/library/alpine:latest
run_test "podman tag" podman tag docker.io/library/alpine:latest my-alpine:test
run_test "podman build" bash -c "mkdir -p /tmp/smoke-build && echo 'FROM docker.io/library/alpine:latest' > /tmp/smoke-build/Dockerfile && podman build -t smoke-build /tmp/smoke-build"

# 3. Container Lifecycle
run_test "podman run detached" podman run -d --name smoke-test docker.io/library/alpine:latest sleep 100
run_test "podman inspect container" podman inspect smoke-test
run_test "podman logs" podman logs smoke-test
run_test "podman exec" podman exec smoke-test echo hello
run_test "podman stop" podman stop smoke-test
run_test "podman rm" podman rm smoke-test

# 4. Volumes
run_test "podman volume create" podman volume create smoke-vol
run_test "podman run with volume" podman run --rm -v smoke-vol:/data docker.io/library/alpine:latest touch /data/test.txt
run_test "podman volume rm" podman volume rm smoke-vol
run_test "podman run host bind mount" bash -c "mkdir -p /tmp/smoke-bind && touch /tmp/smoke-bind/test.txt && podman run --rm -v /tmp/smoke-bind:/data:Z docker.io/library/alpine:latest ls /data/test.txt"

# 5. Networking
run_test "podman network create" podman network create smoke-net
run_test "podman run custom network" bash -c "podman run -d --name net-test --network smoke-net docker.io/library/alpine:latest sleep 100 && podman rm -f net-test"
run_test "podman network rm" podman network rm smoke-net
run_test "podman run port forwarding" bash -c "podman run -d --name port-test -p 8089:80 docker.io/library/nginx:alpine && sleep 3 && curl -s http://localhost:8089 >/dev/null && podman rm -f port-test"

# 6. Pods
run_test "podman pod create" podman pod create --name smoke-pod
run_test "podman run in pod" podman run -d --pod smoke-pod --name pod-cont docker.io/library/alpine:latest sleep 100
run_test "podman pod stop" podman pod stop smoke-pod
run_test "podman pod rm" podman pod rm smoke-pod

# 7. Secrets
run_test "podman secret create" bash -c "echo 'mysecret' | podman secret create smoke-secret -"
run_test "podman run with secret" bash -c "podman run --rm --secret smoke-secret docker.io/library/alpine:latest cat /run/secrets/smoke-secret | grep mysecret"
run_test "podman secret rm" podman secret rm smoke-secret

# 8. Kubernetes
run_test "podman kube generate" bash -c "podman run -d --name kube-test docker.io/library/alpine:latest sleep 100 && podman kube generate kube-test > /tmp/kube.yaml && podman rm -f kube-test"
run_test "podman kube play" bash -c "podman kube play /tmp/kube.yaml && podman kube down /tmp/kube.yaml"

# Cleanup
podman rmi docker.io/library/alpine:latest my-alpine:test smoke-build docker.io/library/nginx:alpine 2>/dev/null || true

echo "--------------------------------"
echo "Tests Passed: $test_passed"
echo "Tests Failed: $test_failed"

exit $test_failed
