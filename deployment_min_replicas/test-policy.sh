#!/bin/bash

echo "Testing Min Replicas Policy"
echo "============================"

echo ""
echo "Test 1: Valid deployment (replicas >= 2)"
opa eval --data policies/min-replicas-enforcement.rego \
        --input test-data/valid-deployment.json \
        "data.wiz.result" | jq -r '.result[0].expressions[0].value // "ERROR"'
echo "Expected: pass"

echo ""
echo "Test 2: Invalid deployment (replicas < 2)"
opa eval --data policies/min-replicas-enforcement.rego \
        --input test-data/invalid-deployment.json \
        "data.wiz.result" | jq -r '.result[0].expressions[0].value // "ERROR"'
echo "Expected: fail"

