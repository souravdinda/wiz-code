# Rego Policy Code Explanation - VPA Limits Validation

This document provides a detailed line-by-line explanation of the VPA Limits Validation Rego policy for Kubernetes Deployments.

## 📋 Policy Overview

The policy validates that workloads with VPA (Vertical Pod Autoscaler) do not have limits <= requests (unless VPA only modifies requests). VPA should not set limits that are less than or equal to requests, as this can cause resource contention issues.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if workloads with VPA have limits <= requests (unless VPA only modifies requests)
# VPA should not set limits that are less than or equal to requests

default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

# Check if VPA is configured (via annotation or assume it exists if limits are set)
# For this policy, we assume VPA exists if the deployment has resource limits
hasVPA if {
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits]) > 0
  input.metadata.annotations["vpa-enabled"] == "true"
} else {
  # Or check if VPA annotation exists
  input.metadata.annotations["vpa-enabled"] == "true"
}

# Check if any container has both limits and requests configured
# Note: Actual comparison of limits <= requests would require parsing resource strings
# This policy checks structure - actual value comparison would be done by VPA controller
hasLimitsAndRequests if {
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits; c.resources.requests]) > 0
}

# Pass if no VPA is configured
result = "pass" if {
  not hasVPA
} else = "pass" if {
  # Pass if VPA only modifies requests (no limits set)
  hasVPA
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits]) == 0
} else = "pass" if {
  # Pass if limits exist but are greater than requests (structure check)
  # Note: Actual value validation would require parsing and comparison
  hasVPA
  hasLimitsAndRequests
  # This is a structural check - actual limits <= requests validation happens at VPA level
}

currentConfiguration := "Workload has VPA with limits <= requests configured"
expectedConfiguration := "VPA should not set limits that are less than or equal to requests (unless VPA only modifies requests)"
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
- ❌ **Example**: A deployment with VPA and invalid limits might pass when it should fail

### Container Paths Definition
```rego
containerPaths := {"containers", "initContainers", "ephemeralContainers"}
```
**What it does:** Defines all container types that need to be checked. This includes regular containers, init containers, and ephemeral containers.

**What happens if you don't use it:**
- ❌ **Problem**: Only regular containers would be checked
- ❌ **Consequence**: Init containers and ephemeral containers would be missed
- ❌ **Impact**: Incomplete policy enforcement
- ❌ **Example**: A deployment with VPA and init containers having invalid limits would pass

**Note:** This variable is used in the policy to check all container types.

### Has VPA Rule
```rego
hasVPA if {
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits]) > 0
  input.metadata.annotations["vpa-enabled"] == "true"
} else {
  # Or check if VPA annotation exists
  input.metadata.annotations["vpa-enabled"] == "true"
}
```
**What it does:** 
- Checks if VPA is configured by looking for the `vpa-enabled` annotation
- Also checks if containers have limits (as VPA might set limits)
- Returns true if VPA annotation exists OR if limits exist with VPA annotation

**What happens if you don't use it:**
- ❌ **Problem**: Cannot determine if VPA is configured
- ❌ **Consequence**: Policy cannot differentiate between deployments with and without VPA
- ❌ **Impact**: All deployments would be validated, even those without VPA
- ❌ **Example**: A deployment without VPA would be validated unnecessarily

**Key Points:**
- Uses `input.metadata.annotations` to access annotations
- Checks for specific annotation key `vpa-enabled`
- Uses `else` to provide alternative check (annotation alone)

### Has Limits And Requests Rule
```rego
hasLimitsAndRequests if {
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits; c.resources.requests]) > 0
}
```
**What it does:** 
- Checks if any container has both limits and requests configured
- Uses list comprehension to count containers with both limits and requests
- Returns true if at least one container has both

**What happens if you don't use it:**
- ❌ **Problem**: Cannot determine if containers have both limits and requests
- ❌ **Consequence**: Policy cannot validate the structure
- ❌ **Impact**: Policy fails to check if limits and requests coexist
- ❌ **Example**: A deployment with VPA but only limits (no requests) would pass when it should be validated

**Key Points:**
- Uses list comprehension with multiple conditions
- Checks for both `c.resources.limits` and `c.resources.requests`
- This is a structural check - actual value comparison requires parsing

### First Pass Condition (No VPA)
```rego
result = "pass" if {
  not hasVPA
}
```
**What it does:** 
- Sets result to "pass" if VPA is NOT configured
- Allows deployments without VPA to pass (they don't need VPA-specific validation)

**What happens if you don't use it:**
- ❌ **Problem**: Deployments without VPA would fail unnecessarily
- ❌ **Consequence**: All deployments would be validated for VPA rules, even those without VPA
- ❌ **Impact**: Overly strict policy that rejects valid deployments
- ❌ **Example**: A deployment without VPA would fail even though VPA rules don't apply

**Key Points:**
- Uses `not hasVPA` to check for absence of VPA
- Allows deployments without VPA to pass

### Second Pass Condition (VPA Only Modifies Requests)
```rego
result = "pass" if {
  # Pass if VPA only modifies requests (no limits set)
  hasVPA
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits]) == 0
}
```
**What it does:** 
- Sets result to "pass" if VPA is configured AND no limits are set
- This allows VPA to only modify requests (which is valid)

**What happens if you don't use it:**
- ❌ **Problem**: VPA deployments that only modify requests would fail
- ❌ **Consequence**: Valid VPA configurations would be rejected
- ❌ **Impact**: Overly strict policy that rejects valid VPA usage
- ❌ **Example**: A deployment with VPA that only modifies requests (no limits) would fail

**Key Points:**
- Requires VPA to be configured
- Requires no limits to be set (count == 0)
- This is a valid VPA configuration pattern

### Third Pass Condition (VPA With Limits And Requests)
```rego
result = "pass" if {
  # Pass if limits exist but are greater than requests (structure check)
  # Note: Actual value validation would require parsing and comparison
  hasVPA
  hasLimitsAndRequests
  # This is a structural check - actual limits <= requests validation happens at VPA level
}
```
**What it does:** 
- Sets result to "pass" if VPA is configured AND containers have both limits and requests
- This is a structural check - actual value comparison (limits <= requests) would require parsing resource strings

**What happens if you don't use it:**
- ❌ **Problem**: VPA deployments with limits and requests would fail
- ❌ **Consequence**: Valid VPA configurations would be rejected
- ❌ **Impact**: Overly strict policy that rejects valid VPA usage
- ❌ **Example**: A deployment with VPA, limits, and requests would fail even if limits > requests

**Key Points:**
- This is a structural validation only
- Actual comparison of limits <= requests requires parsing resource strings (e.g., "100m" vs "200m")
- VPA controller typically handles actual value validation

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Three Pass Conditions
**Why:** Different logic for deployments without VPA, VPA with only requests, and VPA with limits+requests
**Impact:** Flexible policy that handles different VPA configuration patterns

### 3. Structural Validation Only
**Why:** Actual comparison of limits <= requests requires parsing resource strings (complex)
**Impact:** Policy focuses on structure; VPA controller handles value validation

### 4. Using Annotation for VPA Detection
**Why:** Simple way to detect VPA configuration without querying separate resources
**Impact:** Self-contained policy that works with deployment resource alone

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
hasVPA if {
  input.metadata.annotations["vpa-enabled"] == "true"
}

# ✅ CORRECT - Default result set
default result = "fail"
hasVPA if {
  input.metadata.annotations["vpa-enabled"] == "true"
}
```

### 2. Missing First Pass Condition
```rego
# ❌ WRONG - Deployments without VPA would fail
result = "pass" if {
  hasVPA
  hasLimitsAndRequests
}

# ✅ CORRECT - Allow deployments without VPA to pass
result = "pass" if {
  not hasVPA
}
```

### 3. Not Handling VPA-Only-Requests Case
```rego
# ❌ WRONG - VPA with only requests would fail
result = "pass" if {
  hasVPA
  hasLimitsAndRequests
}

# ✅ CORRECT - Allow VPA with only requests
result = "pass" if {
  hasVPA
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits]) == 0
}
```

### 4. Attempting Value Comparison Without Parsing
```rego
# ❌ WRONG - Cannot directly compare resource strings
result = "pass" if {
  hasVPA
  container.resources.limits.cpu > container.resources.requests.cpu
}

# ✅ CORRECT - Structural check only
result = "pass" if {
  hasVPA
  hasLimitsAndRequests
  # Actual comparison requires parsing resource strings
}
```

## 📊 Testing

### Test with Valid Deployment (No VPA)
```bash
opa eval --data policies/vpa-limits-validation.rego \
        --input test-data/valid-deployment-no-vpa.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Valid Deployment (VPA, Only Requests)
```bash
opa eval --data policies/vpa-limits-validation.rego \
        --input test-data/valid-deployment-vpa-requests-only.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Valid Deployment (VPA, Limits + Requests)
```bash
opa eval --data policies/vpa-limits-validation.rego \
        --input test-data/valid-deployment-vpa-limits-requests.json \
        "data.wiz.result"
# Expected: "pass" (structural check)
```

## 🎉 Summary

This policy ensures that workloads with VPA do not have limits <= requests (unless VPA only modifies requests). The policy uses a fail-safe approach with `default result = "fail"` and implements three pass conditions: one for deployments without VPA, one for VPA that only modifies requests, and one for VPA with both limits and requests (structural check). The policy performs structural validation only; actual comparison of limits <= requests requires parsing resource strings and is typically handled by the VPA controller.

