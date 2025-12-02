# Rego Policy Code Explanation - HPA Requests Validation

This document provides a detailed line-by-line explanation of the HPA Requests Validation Rego policy for Kubernetes Deployments.

## 📋 Policy Overview

The policy validates that Kubernetes Deployments with HPA (Horizontal Pod Autoscaler) have CPU and memory requests configured for all containers. HPA requires resource requests to function properly for scaling decisions based on resource utilization.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if workloads with HPA have CPU and memory requests configured
# HPA requires resource requests to function properly for scaling decisions

default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

# Check if HPA is configured (via annotation)
hasHPA if {
  input.metadata.annotations["hpa-enabled"] == "true"
}

# Check if all containers have CPU requests
allContainersHaveCPURequests if {
  count([c | c := input.spec.template.spec.containers[_]; not c.resources.requests.cpu]) == 0
  count([c | c := input.spec.template.spec.initContainers[_]; not c.resources.requests.cpu]) == 0
  count([c | c := input.spec.template.spec.ephemeralContainers[_]; not c.resources.requests.cpu]) == 0
  count(input.spec.template.spec.containers) > 0
}

# Check if all containers have memory requests
allContainersHaveMemoryRequests if {
  count([c | c := input.spec.template.spec.containers[_]; not c.resources.requests.memory]) == 0
  count([c | c := input.spec.template.spec.initContainers[_]; not c.resources.requests.memory]) == 0
  count([c | c := input.spec.template.spec.ephemeralContainers[_]; not c.resources.requests.memory]) == 0
  count(input.spec.template.spec.containers) > 0
}

# Pass if no HPA is configured
result = "pass" if {
  not hasHPA
}

# Pass if HPA is configured and all containers have requests
result = "pass" if {
  hasHPA
  allContainersHaveCPURequests
  allContainersHaveMemoryRequests
}

currentConfiguration := "Deployment has HPA configured but is missing CPU or memory requests"
expectedConfiguration := "Deployments with HPA should have CPU and memory requests configured for all containers"
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

### Default Result
```rego
default result = "fail"
```
**What it does:** Sets the default result to "fail". This means the policy will fail by default unless the pass condition is met.

**What happens if you don't use it:**
- ❌ **Problem**: Policy may return undefined results
- ❌ **Consequence**: Unpredictable behavior
- ❌ **Impact**: Policy enforcement becomes unreliable
- ❌ **Example**: A deployment with HPA but missing requests might pass when it should fail

### Container Paths Definition
```rego
containerPaths := {"containers", "initContainers", "ephemeralContainers"}
```
**What it does:** Defines all container types that need to be checked. This includes regular containers, init containers, and ephemeral containers.

**What happens if you don't use it:**
- ❌ **Problem**: Only regular containers would be checked
- ❌ **Consequence**: Init containers and ephemeral containers without requests would be missed
- ❌ **Impact**: Incomplete policy enforcement
- ❌ **Example**: A deployment with HPA and init containers without requests would pass when it should fail

**Note:** While this variable is defined, the policy explicitly checks each container type separately for clarity.

### Has HPA Rule
```rego
hasHPA if {
  input.metadata.annotations["hpa-enabled"] == "true"
}
```
**What it does:** 
- Checks if HPA is configured by looking for the `hpa-enabled` annotation
- Returns true if the annotation exists and is set to "true"

**What happens if you don't use it:**
- ❌ **Problem**: Cannot determine if HPA is configured
- ❌ **Consequence**: Policy cannot differentiate between deployments with and without HPA
- ❌ **Impact**: All deployments would be required to have requests, even those without HPA
- ❌ **Example**: A deployment without HPA would fail unnecessarily

**Key Points:**
- Uses `input.metadata.annotations` to access annotations
- Checks for specific annotation key `hpa-enabled`
- In a real environment, HPA existence might be checked via separate HPA resources

### All Containers Have CPU Requests Rule
```rego
allContainersHaveCPURequests if {
  count([c | c := input.spec.template.spec.containers[_]; not c.resources.requests.cpu]) == 0
  count([c | c := input.spec.template.spec.initContainers[_]; not c.resources.requests.cpu]) == 0
  count([c | c := input.spec.template.spec.ephemeralContainers[_]; not c.resources.requests.cpu]) == 0
  count(input.spec.template.spec.containers) > 0
}
```
**What it does:** 
- Uses list comprehension to count containers missing CPU requests
- Checks all three container types: containers, initContainers, ephemeralContainers
- Returns true only if:
  - No containers are missing CPU requests (count == 0 for all types)
  - At least one container exists (ensures deployment has containers)

**What happens if you don't use it:**
- ❌ **Problem**: Cannot validate CPU requests
- ❌ **Consequence**: Containers without CPU requests would pass
- ❌ **Impact**: Policy fails to enforce CPU requests for HPA
- ❌ **Example**: A deployment with HPA but containers missing CPU requests would pass

**Key Points:**
- Uses `not c.resources.requests.cpu` to identify containers missing requests
- Checks all container types separately for clarity
- Ensures at least one container exists before validating

### All Containers Have Memory Requests Rule
```rego
allContainersHaveMemoryRequests if {
  count([c | c := input.spec.template.spec.containers[_]; not c.resources.requests.memory]) == 0
  count([c | c := input.spec.template.spec.initContainers[_]; not c.resources.requests.memory]) == 0
  count([c | c := input.spec.template.spec.ephemeralContainers[_]; not c.resources.requests.memory]) == 0
  count(input.spec.template.spec.containers) > 0
}
```
**What it does:** 
- Uses list comprehension to count containers missing memory requests
- Checks all three container types: containers, initContainers, ephemeralContainers
- Returns true only if:
  - No containers are missing memory requests (count == 0 for all types)
  - At least one container exists (ensures deployment has containers)

**What happens if you don't use it:**
- ❌ **Problem**: Cannot validate memory requests
- ❌ **Consequence**: Containers without memory requests would pass
- ❌ **Impact**: Policy fails to enforce memory requests for HPA
- ❌ **Example**: A deployment with HPA but containers missing memory requests would pass

**Key Points:**
- Uses `not c.resources.requests.memory` to identify containers missing requests
- Checks all container types separately for clarity
- Ensures at least one container exists before validating

### First Pass Condition (No HPA)
```rego
result = "pass" if {
  not hasHPA
}
```
**What it does:** 
- Sets result to "pass" if HPA is NOT configured
- Allows deployments without HPA to pass (they don't need requests for HPA)

**What happens if you don't use it:**
- ❌ **Problem**: Deployments without HPA would fail unnecessarily
- ❌ **Consequence**: All deployments would be required to have requests, even those without HPA
- ❌ **Impact**: Overly strict policy that rejects valid deployments
- ❌ **Example**: A deployment without HPA would fail even though requests aren't required for HPA

**Key Points:**
- Uses `not hasHPA` to check for absence of HPA
- Allows deployments without HPA to pass

### Second Pass Condition (HPA with Requests)
```rego
result = "pass" if {
  hasHPA
  allContainersHaveCPURequests
  allContainersHaveMemoryRequests
}
```
**What it does:** 
- Sets result to "pass" if HPA is configured AND all containers have both CPU and memory requests
- Ensures deployments with HPA have the required requests

**What happens if you don't use it:**
- ❌ **Problem**: No way for HPA deployments to pass
- ❌ **Consequence**: All deployments with HPA would fail, even if they have requests
- ❌ **Impact**: Valid deployments with HPA and requests would be rejected
- ❌ **Example**: A deployment with HPA and proper requests would fail

**Key Points:**
- Requires all three conditions: HPA, CPU requests, and memory requests
- Ensures deployments with HPA have complete request configuration

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Two Pass Conditions
**Why:** Different logic for deployments with and without HPA
**Impact:** Flexible policy that only enforces requests when HPA is configured

### 3. Checking All Container Types
**Why:** All container types need requests for HPA to function properly
**Impact:** Comprehensive policy enforcement across all container types

### 4. Using Annotation for HPA Detection
**Why:** Simple way to detect HPA configuration without querying separate resources
**Impact:** Self-contained policy that works with deployment resource alone

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
hasHPA if {
  input.metadata.annotations["hpa-enabled"] == "true"
}

# ✅ CORRECT - Default result set
default result = "fail"
hasHPA if {
  input.metadata.annotations["hpa-enabled"] == "true"
}
```

### 2. Missing First Pass Condition
```rego
# ❌ WRONG - Deployments without HPA would fail
result = "pass" if {
  hasHPA
  allContainersHaveCPURequests
  allContainersHaveMemoryRequests
}

# ✅ CORRECT - Allow deployments without HPA to pass
result = "pass" if {
  not hasHPA
}
result = "pass" if {
  hasHPA
  allContainersHaveCPURequests
  allContainersHaveMemoryRequests
}
```

### 3. Not Checking All Container Types
```rego
# ❌ WRONG - Only checks regular containers
allContainersHaveCPURequests if {
  count([c | c := input.spec.template.spec.containers[_]; not c.resources.requests.cpu]) == 0
}

# ✅ CORRECT - Checks all container types
allContainersHaveCPURequests if {
  count([c | c := input.spec.template.spec.containers[_]; not c.resources.requests.cpu]) == 0
  count([c | c := input.spec.template.spec.initContainers[_]; not c.resources.requests.cpu]) == 0
  count([c | c := input.spec.template.spec.ephemeralContainers[_]; not c.resources.requests.cpu]) == 0
  count(input.spec.template.spec.containers) > 0
}
```

### 4. Missing Memory Requests Check
```rego
# ❌ WRONG - Only checks CPU requests
result = "pass" if {
  hasHPA
  allContainersHaveCPURequests
}

# ✅ CORRECT - Checks both CPU and memory requests
result = "pass" if {
  hasHPA
  allContainersHaveCPURequests
  allContainersHaveMemoryRequests
}
```

## 📊 Testing

### Test with Valid Deployment (HPA + Requests)
```bash
opa eval --data policies/hpa-requests-validation.rego \
        --input test-data/valid-deployment-with-requests.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Deployment (HPA, Missing Requests)
```bash
opa eval --data policies/hpa-requests-validation.rego \
        --input test-data/invalid-deployment-missing-requests.json \
        "data.wiz.result"
# Expected: "fail"
```

### Test with Valid Deployment (No HPA)
```bash
opa eval --data policies/hpa-requests-validation.rego \
        --input test-data/valid-deployment-no-hpa.json \
        "data.wiz.result"
# Expected: "pass"
```

## 🎉 Summary

This policy ensures that Kubernetes Deployments with HPA have CPU and memory requests configured for all containers. The policy uses a fail-safe approach with `default result = "fail"` and implements two pass conditions: one for deployments without HPA (which don't need requests for HPA) and one for deployments with HPA (which must have both CPU and memory requests). This provides flexible enforcement that only requires requests when HPA is actually configured, ensuring HPA can function properly for scaling decisions.

