#!/bin/bash

echo "Testing HPA Requests Validation Policy"
echo "======================================="

echo ""
echo "Test 1: Valid deployment with HPA and requests"
opa eval --data policies/hpa-requests-validation.rego \
        --input test-data/valid-deployment-with-requests.json \
        "data.wiz.result" | jq -r '.result[0].expressions[0].value // "ERROR"'
echo "Expected: pass"

echo ""
echo "Test 2: Invalid deployment with HPA but missing requests"
opa eval --data policies/hpa-requests-validation.rego \
        --input test-data/invalid-deployment-missing-requests.json \
        "data.wiz.result" | jq -r '.result[0].expressions[0].value // "ERROR"'
echo "Expected: fail"

echo ""
echo "Test 3: Valid deployment without HPA"
opa eval --data policies/hpa-requests-validation.rego \
        --input test-data/valid-deployment-no-hpa.json \
        "data.wiz.result" | jq -r '.result[0].expressions[0].value // "ERROR"'
echo "Expected: pass"

