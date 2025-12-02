#!/bin/bash

echo "Testing Topology Spread Constraints Policy"
echo "=========================================="

echo ""
echo "Test 1: Valid deployment with constraints (replicas > 2, has constraints)"
opa eval --data policies/topology-spread-constraints-enforcement.rego \
        --input test-data/valid-deployment-with-constraints.json \
        "data.wiz.result" | jq -r '.result[0].expressions[0].value // "ERROR"'
echo "Expected: pass"

echo ""
echo "Test 2: Valid deployment with low replicas (replicas <= 2)"
opa eval --data policies/topology-spread-constraints-enforcement.rego \
        --input test-data/valid-deployment-low-replicas.json \
        "data.wiz.result" | jq -r '.result[0].expressions[0].value // "ERROR"'
echo "Expected: pass"

echo ""
echo "Test 3: Invalid deployment (replicas > 2, missing constraints)"
opa eval --data policies/topology-spread-constraints-enforcement.rego \
        --input test-data/invalid-deployment-missing-constraints.json \
        "data.wiz.result" | jq -r '.result[0].expressions[0].value // "ERROR"'
echo "Expected: fail"
