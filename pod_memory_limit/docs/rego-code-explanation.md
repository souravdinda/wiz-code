# Rego Policy Code Explanation - Line by Line

This document provides a detailed line-by-line explanation of the Memory Limit Enforcement Rego policy, including what happens if you don't use each block.

## 📋 Policy Overview

The policy validates that all Kubernetes Pod containers have memory limits configured to prevent resource contention and unpredictable performance.

## 🔍 Complete Policy Code

```rego
package wiz

# Invesco-Memory Limits Not Set
# This rule checks if Kubernetes pods have memory limits configured for all containers
# Pods without memory limits can lead to resource contention and unpredictable performance
default result = "pass"

currentConfiguration := sprintf("Pod '%s' containers without memory limits: %v", [input.metadata.name, containers_without_memory_limits])
expectedConfiguration := "All containers should have memory limits specified in their resource requirements"

# Get containers that don't have memory limits set
containers_without_memory_limits := [container.name | 
    container := input.spec.containers[_]
    not container.resources.limits.memory
]

result = "fail" if {
    count(containers_without_memory_limits) > 0
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
# Invesco-Memory Limits Not Set
# This rule checks if Kubernetes pods have memory limits configured for all containers
# Pods without memory limits can lead to resource contention and unpredictable performance
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
currentConfiguration := sprintf("Pod '%s' containers without memory limits: %v", [input.metadata.name, containers_without_memory_limits])
```
**What it does:** Creates a descriptive message showing which containers are missing memory limits.

**What happens if you don't use it:**
- ⚠️ **Problem**: No detailed error message
- ⚠️ **Consequence**: Users won't know which containers are problematic
- ⚠️ **Impact**: Poor user experience - difficult to identify and fix issues
- ⚠️ **Example**: Users get a generic failure without knowing which containers need fixing

### Expected Configuration Message - Line 9
```rego
expectedConfiguration := "All containers should have memory limits specified in their resource requirements"
```
**What it does:** Defines the expected configuration that should be met.

**What happens if you don't use it:**
- ⚠️ **Problem**: No guidance on what's expected
- ⚠️ **Consequence**: Users don't know what the policy requires
- ⚠️ **Impact**: Poor user experience - unclear remediation steps
- ⚠️ **Example**: Users won't know they need to add memory limits to containers

### Container List Comprehension - Lines 11-15
```rego
# Get containers that don't have memory limits set
containers_without_memory_limits := [container.name | 
    container := input.spec.containers[_]
    not container.resources.limits.memory
]
```
**What it does:** Uses a list comprehension to collect all container names that don't have memory limits configured.

**What happens if you don't use it:**
- ❌ **Problem**: Cannot identify problematic containers
- ❌ **Consequence**: Policy cannot determine which containers are missing memory limits
- ❌ **Impact**: Policy fails to work - no way to check container memory limits
- ❌ **Example**: Policy would fail to detect containers without memory limits

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

### Memory Limit Check - Line 14
```rego
not container.resources.limits.memory
```
**What it does:** Checks if the container is missing a memory limit by verifying that `container.resources.limits.memory` is not set.

**What happens if you don't use it:**
- ❌ **Problem**: No memory limit validation
- ❌ **Consequence**: Containers without memory limits will be allowed
- ❌ **Impact**: Policy becomes useless - no enforcement of memory limits
- ❌ **Example**: A container with no memory limit would be allowed

### Failure Condition - Lines 17-19
```rego
result = "fail" if {
    count(containers_without_memory_limits) > 0
}
```
**What it does:** Sets the result to "fail" if there are any containers without memory limits.

**What happens if you don't use it:**
- ❌ **Problem**: No failure condition
- ❌ **Consequence**: Policy will always pass, even when containers are missing memory limits
- ❌ **Impact**: Policy becomes useless - no enforcement occurs
- ❌ **Example**: Pods without memory limits would pass validation

### Skip Condition - Lines 21-23
```rego
result = "skip" if {
    input.kind != "Pod"
}
```
**What it does:** Skips evaluation for resources that are not Pods, since this policy only applies to Pod resources.

**What happens if you don't use it:**
- ❌ **Problem**: Policy applies to ALL resources
- ❌ **Consequence**: Services, ConfigMaps, Secrets, etc. will be checked for memory limits
- ❌ **Impact**: False positives - non-Pod resources will be evaluated incorrectly
- ❌ **Example**: A Service resource will be checked for container memory limits, which doesn't make sense

## 🔄 Policy Flow Diagram

```
Input Resource
     ↓
Is it a Pod? (input.kind == "Pod")
     ↓ Yes
Get all containers (input.spec.containers[_])
     ↓
For each container:
Has memory limit? (container.resources.limits.memory)
     ↓ No
Add to containers_without_memory_limits
     ↓
Any containers without limits? (count > 0)
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
**Why:** Fails only when there are actual containers missing memory limits
**Impact:** Allows pods with all containers properly configured to pass

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
result = "fail" if {
    count(containers_without_memory_limits) > 0
}

# ✅ CORRECT - Default result set
default result = "pass"
result = "fail" if {
    count(containers_without_memory_limits) > 0
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
    count(containers_without_memory_limits) > 0
}

# ✅ CORRECT - Only applies to Pods
result = "skip" if {
    input.kind != "Pod"
}
result = "fail" if {
    count(containers_without_memory_limits) > 0
}
```

### 4. Incorrect Memory Limit Check
```rego
# ❌ WRONG - Checks if memory limit exists (opposite logic)
container.resources.limits.memory

# ✅ CORRECT - Checks if memory limit is missing
not container.resources.limits.memory
```

## 📊 Testing Each Block

### Test Default Result
```bash
# Test with valid pod
opa eval --data policies/memory-limit-enforcement.rego --input test-data/valid-pod.json 'data.wiz.result'
# Expected: "pass"
```

### Test Container Extraction
```bash
# Test container extraction
opa eval --data policies/memory-limit-enforcement.rego --input test-data/valid-pod.json 'data.wiz.containers_without_memory_limits'
# Expected: [] (empty array)
```

### Test Failure Condition
```bash
# Test with invalid pod
opa eval --data policies/memory-limit-enforcement.rego --input test-data/invalid-pod.json 'data.wiz.result'
# Expected: "fail"
```

### Test Skip Condition
```bash
# Test with non-Pod resource
opa eval --data policies/memory-limit-enforcement.rego --input test-data/not-pod-deployment.json 'data.wiz.result'
# Expected: "skip"
```

## 🎉 Summary

Each block in the Rego policy serves a specific purpose:

- **Package Declaration**: Required for policy compilation
- **Default Result**: Ensures policy always returns a result
- **Current/Expected Configuration**: Provides clear error messages
- **Container List Comprehension**: Identifies all containers missing memory limits
- **Container Iteration**: Checks each container individually
- **Memory Limit Check**: Validates memory limit presence
- **Failure Condition**: Enforces policy when violations are found
- **Skip Condition**: Prevents false positives on non-Pod resources

**Removing any block will break the policy functionality or reduce its effectiveness.** The policy is designed as an integrated system where each component depends on the others for proper operation.

