# Rego Policy Code Explanation - Line by Line

This document provides a detailed line-by-line explanation of the Memory Request Enforcement Rego policy, including what happens if you don't use each block.

## 📋 Policy Overview

The policy validates that all Kubernetes Pod containers have memory requests configured to prevent resource contention and unpredictable performance.

## 🔍 Complete Policy Code

```rego
package wiz

# Invesco-Memory Requests Not Set
# This rule checks if Kubernetes pods have memory requests configured for all containers
# Pods without memory requests can lead to resource contention and unpredictable performance
default result = "pass"

currentConfiguration := sprintf("Pod '%s' containers without memory requests: %v", [input.metadata.name, containers_without_memory_requests])
expectedConfiguration := "All containers should have memory requests specified in their resource requirements"

# Get containers that don't have memory requests set
containers_without_memory_requests := [container.name | 
    container := input.spec.containers[_]
    not container.resources.requests.memory
]

result = "fail" if {
    count(containers_without_memory_requests) > 0
}

result = "skip" if {
    input.kind != "Pod"
}
```

## 📝 Line-by-Line Explanation

### Package Declaration
```rego
package wiz
```
**What it does:** Declares the package name for the policy. This creates a namespace for all rules and functions in this policy.

**What happens if you don't use it:** 
- ❌ **Error**: OPA requires a package declaration
- ❌ **Consequence**: Policy won't compile
- ❌ **Impact**: Cannot be deployed to Wiz

### Policy Comments - Lines 3-5
```rego
# Invesco-Memory Requests Not Set
# This rule checks if Kubernetes pods have memory requests configured for all containers
# Pods without memory requests can lead to resource contention and unpredictable performance
```
**What it does:** Provides documentation explaining the purpose and importance of the policy.

**What happens if you don't use it:**
- ⚠️ **Warning**: No documentation
- ⚠️ **Consequence**: Difficult to understand policy purpose
- ✅ **Impact**: Policy still works but lacks documentation

### Default Result - Line 6
```rego
default result = "pass"
```
**What it does:** Sets the default result to "pass", meaning the policy passes unless a failure condition is met.

**What happens if you don't use it:**
- ❌ **Problem**: Result may be undefined
- ❌ **Consequence**: Policy evaluation may fail or return unexpected results
- ❌ **Impact**: Unpredictable behavior - pods may not be properly evaluated
- ❌ **Example**: Without a default, the result might be undefined for valid pods

### Current Configuration Message - Line 8
```rego
currentConfiguration := sprintf("Pod '%s' containers without memory requests: %v", [input.metadata.name, containers_without_memory_requests])
```
**What it does:** Creates a descriptive message showing which containers are missing memory requests.

**What happens if you don't use it:**
- ⚠️ **Problem**: No detailed error message
- ⚠️ **Consequence**: Users won't know which containers are problematic
- ⚠️ **Impact**: Poor user experience - difficult to identify and fix issues
- ⚠️ **Example**: Users get a generic failure without knowing which containers need fixing

### Expected Configuration Message - Line 9
```rego
expectedConfiguration := "All containers should have memory requests specified in their resource requirements"
```
**What it does:** Defines the expected configuration that should be met.

**What happens if you don't use it:**
- ⚠️ **Problem**: No guidance on what's expected
- ⚠️ **Consequence**: Users don't know what the policy requires
- ⚠️ **Impact**: Poor user experience - unclear remediation steps
- ⚠️ **Example**: Users won't know they need to add memory requests to containers

### Container List Comprehension - Lines 11-15
```rego
# Get containers that don't have memory requests set
containers_without_memory_requests := [container.name | 
    container := input.spec.containers[_]
    not container.resources.requests.memory
]
```
**What it does:** Uses a list comprehension to collect all container names that don't have memory requests configured.

**What happens if you don't use it:**
- ❌ **Problem**: Cannot identify problematic containers
- ❌ **Consequence**: Policy cannot determine which containers are missing memory requests
- ❌ **Impact**: Policy fails to work - no way to check container memory requests
- ❌ **Example**: Policy would fail to detect containers without memory requests

### Container Iteration - Line 13
```rego
container := input.spec.containers[_]
```
**What it does:** Iterates through each container in the pod's spec.containers array.

**What happens if you don't use it:**
- ❌ **Problem**: Cannot check individual containers
- ❌ **Consequence**: Only checks the first container or fails entirely
- ❌ **Impact**: Multi-container pods won't be properly validated
- ❌ **Example**: A pod with 3 containers - only the first one would be checked

### Memory Request Check - Line 14
```rego
not container.resources.requests.memory
```
**What it does:** Checks if the container is missing a memory request by verifying that `container.resources.requests.memory` is not set.

**What happens if you don't use it:**
- ❌ **Problem**: No memory request validation
- ❌ **Consequence**: Containers without memory requests will be allowed
- ❌ **Impact**: Policy becomes useless - no enforcement of memory requests
- ❌ **Example**: A container with no memory request would be allowed

### Failure Condition - Lines 17-19
```rego
result = "fail" if {
    count(containers_without_memory_requests) > 0
}
```
**What it does:** Sets the result to "fail" if there are any containers without memory requests.

**What happens if you don't use it:**
- ❌ **Problem**: No failure condition
- ❌ **Consequence**: Policy will always pass, even when containers are missing memory requests
- ❌ **Impact**: Policy becomes useless - no enforcement occurs
- ❌ **Example**: Pods without memory requests would pass validation

### Skip Condition - Lines 21-23
```rego
result = "skip" if {
    input.kind != "Pod"
}
```
**What it does:** Skips evaluation for resources that are not Pods, since this policy only applies to Pod resources.

**What happens if you don't use it:**
- ❌ **Problem**: Policy applies to ALL resources
- ❌ **Consequence**: Services, ConfigMaps, Secrets, etc. will be checked for memory requests
- ❌ **Impact**: False positives - non-Pod resources will be evaluated incorrectly
- ❌ **Example**: A Service resource will be checked for container memory requests, which doesn't make sense

## 🔄 Policy Flow Diagram

```
Input Resource
     ↓
Is it a Pod? (input.kind == "Pod")
     ↓ Yes
Get all containers (input.spec.containers[_])
     ↓
For each container:
Has memory request? (container.resources.requests.memory)
     ↓ No
Add to containers_without_memory_requests
     ↓
Any containers without requests? (count > 0)
     ↓ Yes
Set result = "fail"
     ↓
Return result
```

## 🎯 Key Design Decisions

### 1. Default Result to "pass"
**Why:** Assumes pods are compliant unless proven otherwise
**Impact:** Reduces false positives and allows valid pods to pass quickly

### 2. List Comprehension for Container Collection
**Why:** Efficiently collects all problematic containers in one pass
**Impact:** Provides detailed error messages showing all containers that need fixing

### 3. Skip Non-Pod Resources
**Why:** Policy only applies to Pod resources that have containers
**Impact:** Prevents false positives on Services, ConfigMaps, and other non-container resources

### 4. Count-Based Failure Condition
**Why:** Fails only when there are actual containers missing memory requests
**Impact:** Allows pods with all containers properly configured to pass

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
result = "fail" if {
    count(containers_without_memory_requests) > 0
}

# ✅ CORRECT - Default result set
default result = "pass"
result = "fail" if {
    count(containers_without_memory_requests) > 0
}
```

### 2. Incorrect Container Path
```rego
# ❌ WRONG - Wrong path for containers
container := input.containers[_]

# ✅ CORRECT - Correct path for Pod containers
container := input.spec.containers[_]
```

### 3. Missing Skip Condition
```rego
# ❌ WRONG - Applies to all resources
result = "fail" if {
    count(containers_without_memory_requests) > 0
}

# ✅ CORRECT - Only applies to Pods
result = "skip" if {
    input.kind != "Pod"
}
result = "fail" if {
    count(containers_without_memory_requests) > 0
}
```

### 4. Incorrect Memory Request Check
```rego
# ❌ WRONG - Checks if memory request exists (opposite logic)
container.resources.requests.memory

# ✅ CORRECT - Checks if memory request is missing
not container.resources.requests.memory
```

## 📊 Testing Each Block

### Test Default Result
```bash
# Test with valid pod
opa eval --data policies/memory-request-enforcement.rego --input test-data/valid-pod.json 'data.wiz.result'
# Expected: "pass"
```

### Test Container Extraction
```bash
# Test container extraction
opa eval --data policies/memory-request-enforcement.rego --input test-data/valid-pod.json 'data.wiz.containers_without_memory_requests'
# Expected: [] (empty array)
```

### Test Failure Condition
```bash
# Test with invalid pod
opa eval --data policies/memory-request-enforcement.rego --input test-data/invalid-pod.json 'data.wiz.result'
# Expected: "fail"
```

### Test Skip Condition
```bash
# Test with non-Pod resource
opa eval --data policies/memory-request-enforcement.rego --input test-data/not-pod-deployment.json 'data.wiz.result'
# Expected: "skip"
```

## 🎉 Summary

Each block in the Rego policy serves a specific purpose:

- **Package Declaration**: Required for policy compilation
- **Default Result**: Ensures policy always returns a result
- **Current/Expected Configuration**: Provides clear error messages
- **Container List Comprehension**: Identifies all containers missing memory requests
- **Container Iteration**: Checks each container individually
- **Memory Request Check**: Validates memory request presence
- **Failure Condition**: Enforces policy when violations are found
- **Skip Condition**: Prevents false positives on non-Pod resources

**Removing any block will break the policy functionality or reduce its effectiveness.** The policy is designed as an integrated system where each component depends on the others for proper operation.

