#!/bin/bash

# Test script for Memory Request Enforcement Policy
# This script tests the Rego policy against various test cases

set -e

POLICY_FILE="policies/memory-request-enforcement.rego"
TEST_DIR="test-data"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Testing Memory Request Enforcement Policy"
echo "==========================================="
echo ""

# Check if OPA is installed
if ! command -v opa &> /dev/null; then
    echo -e "${RED}Error: OPA is not installed. Please install OPA first.${NC}"
    echo "Installation: brew install opa (macOS) or visit https://www.openpolicyagent.org/docs/latest/#running-opa"
    exit 1
fi

# Check if policy file exists
if [ ! -f "$POLICY_FILE" ]; then
    echo -e "${RED}Error: Policy file not found: $POLICY_FILE${NC}"
    exit 1
fi

# Test counter
PASSED=0
FAILED=0

# Function to test a single case
test_case() {
    local test_file=$1
    local expected=$2
    local description=$3
    
    echo -n "Test: $(basename $test_file) - $description ... "
    
    if [ ! -f "$TEST_DIR/$test_file" ]; then
        echo -e "${RED}FAILED${NC} (file not found)"
        ((FAILED++))
        return
    fi
    
    # Run OPA evaluation
    result=$(opa eval --data "$POLICY_FILE" \
                      --input "$TEST_DIR/$test_file" \
                      "data.wiz.result" 2>/dev/null | jq -r '.result[0].expressions[0].value' 2>/dev/null || echo "pass")
    
    # Map result to expected
    if [ "$result" == "fail" ]; then
        actual="DENIED"
    elif [ "$result" == "skip" ]; then
        actual="SKIPPED"
    else
        actual="ALLOWED"
    fi
    
    # Map expected to result format
    if [ "$expected" == "DENIED" ]; then
        expected_result="fail"
    elif [ "$expected" == "SKIPPED" ]; then
        expected_result="skip"
    else
        expected_result="pass"
    fi
    
    if [ "$result" == "$expected_result" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        echo "   Expected: $expected ($expected_result), Got: $actual ($result)"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo "   Expected: $expected ($expected_result), Got: $actual ($result)"
        ((FAILED++))
    fi
    echo ""
}

# Run test cases
echo "Running test cases..."
echo ""

# Valid cases (should be ALLOWED/pass)
test_case "valid-pod.json" "ALLOWED" "Pod with memory request"
test_case "valid-pod-multi-container.json" "ALLOWED" "Pod with multiple containers, all have memory requests"

# Invalid cases (should be DENIED/fail)
test_case "invalid-pod.json" "DENIED" "Pod missing memory request (has limits only)"
test_case "invalid-pod-no-resources.json" "DENIED" "Pod with no resources section"
test_case "invalid-pod-one-container-missing-request.json" "DENIED" "Pod with one container missing memory request"

# Non-Pod resources (should be SKIPPED)
test_case "not-pod-deployment.json" "SKIPPED" "Deployment (not a Pod, policy doesn't apply)"

# Summary
echo "======================================"
echo "Test Summary:"
echo -e "${GREEN}Passed: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Failed: $FAILED${NC}"
    echo ""
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
fi

