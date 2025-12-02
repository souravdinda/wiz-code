# Rego Policy Code Explanation - CPU Requests Enforcement

This document provides a detailed line-by-line explanation of the CPU Requests Enforcement Rego policy for Kubernetes Deployments.

## 📋 Policy Overview

The policy validates that all Kubernetes Deployment containers (including initContainers and ephemeralContainers) have CPU requests configured to help Kubernetes scheduler make better placement decisions.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if Kubernetes pods have CPU requests configured for all containers
# Pods without CPU requests can lead to resource contention and unpredictable performance
default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

result = "pass" {
  input.spec.template.spec[containerPaths[]][].resources.requests.cpu
}

currentConfiguration := "CPU requests are not set for containers in the deployment"
expectedConfiguration := "CPU requests should be set for all containers in the deployment"
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

### Container Paths Definition
```rego
containerPaths := {"containers", "initContainers", "ephemeralContainers"}
```
**What it does:** Defines all container types that need to be checked. This includes regular containers, init containers, and ephemeral containers.

**What happens if you don't use it:**
- ❌ **Problem**: Only regular containers would be checked
- ❌ **Consequence**: Init containers and ephemeral containers without CPU limits would be missed
- ❌ **Impact**: Incomplete policy enforcement

### Pass Condition
```rego
result = "pass" {
  input.spec.template.spec[containerPaths[]][].resources.requests.cpu
}
```
**What it does:** 
- Uses the `containerPaths[]` syntax to iterate through all container types
- Checks if all containers across all types have CPU requests defined
- Returns "pass" only if every container in every container type has a CPU request

**What happens if you don't use it:**
- ❌ **Problem**: Cannot validate CPU request configuration
- ❌ **Consequence**: Containers without CPU requests would pass
- ❌ **Impact**: Policy fails to enforce CPU requests

**Key Points:**
- Uses `input.spec.template.spec[containerPaths[]][]` to iterate through all container types
- The `containerPaths[]` syntax is a Wiz-specific extension that expands to check all container types simultaneously
- Checks `resources.requests.cpu` for each container

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Checking All Container Types
**Why:** All container types (containers, initContainers, ephemeralContainers) need CPU requests
**Impact:** Comprehensive policy enforcement across all container types

### 3. Container Paths Array Syntax
**Why:** Efficient way to check all container types in a single expression
**Impact:** Clean, concise policy code that's easy to maintain

### 4. Using input.spec (not input.object)
**Why:** This policy uses `input.spec` directly for the resource specification
**Impact:** Correct path for this specific policy pattern

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
result = "pass" {
  input.spec.template.spec[containerPaths[]][].resources.limits.cpu
}

# ✅ CORRECT - Default result set
default result = "fail"
result = "pass" {
  input.spec.template.spec[containerPaths[]][].resources.limits.cpu
}
```

### 2. Missing Container Paths Definition
```rego
# ❌ WRONG - No container paths defined
result = "pass" {
  input.spec.template.spec.containers[].resources.limits.cpu
}

# ✅ CORRECT - Container paths defined
containerPaths := {"containers", "initContainers", "ephemeralContainers"}
result = "pass" {
  input.spec.template.spec[containerPaths[]][].resources.limits.cpu
}
```

### 3. Incorrect Path for Deployment
```rego
# ❌ WRONG - Wrong path (this is for Pods)
input.spec[containerPaths[]][].resources.limits.cpu

# ✅ CORRECT - Correct path for Deployments
input.spec.template.spec[containerPaths[]][].resources.limits.cpu
```

### 4. Wrong Resource Path
```rego
# ❌ WRONG - Checks limits instead of requests
input.spec.template.spec[containerPaths[]][].resources.limits.cpu

# ✅ CORRECT - Checks requests
input.spec.template.spec[containerPaths[]][].resources.requests.cpu
```

## 📊 Testing

### Test with Valid Deployment
```bash
opa eval --data policies/cpu-requests-enforcement.rego \
        --input test-data/valid-deployment.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Deployment
```bash
opa eval --data policies/cpu-requests-enforcement.rego \
        --input test-data/invalid-deployment-missing-cpu-request.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that all containers in Kubernetes Deployments have CPU requests configured. The policy uses a fail-safe approach with `default result = "fail"` and comprehensively checks all container types using the `containerPaths[]` syntax, which is a Wiz-specific extension that efficiently validates all container types in a single expression.
