# Rego Policy Code Explanation - Readiness Probes Enforcement

This document provides a detailed line-by-line explanation of the Readiness Probes Enforcement Rego policy for Kubernetes Pods.

## 📋 Policy Overview

The policy validates that Kubernetes Pod containers (including initContainers and ephemeralContainers) have readiness probes configured to ensure containers are ready to serve traffic before receiving requests.

## 🔍 Complete Policy Code

```rego
package wiz

# Check if Pod has custom readiness probes defined for containers

default result = "fail"

# Check if any container has a readiness probe defined

hasReadinessProbe {
    input.object.spec.containers[_].readinessProbe
}

# Check if any init container has a readiness probe defined

hasInitContainerReadinessProbe {
    input.object.spec.initContainers[_].readinessProbe
}

# Check if any ephemeral container has a readiness probe defined

hasEphemeralContainerReadinessProbe {
    input.object.spec.ephemeralContainers[_].readinessProbe
}

result = "pass" {
    hasReadinessProbe
} else = "pass" {
    hasInitContainerReadinessProbe
} else = "pass" {
    hasEphemeralContainerReadinessProbe
}

currentConfiguration := "Pod containers do not have readiness probes configured"
expectedConfiguration := "Pod containers should have readiness probes configured to ensure proper health checking"
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

### Check Regular Containers
```rego
hasReadinessProbe {
    input.object.spec.template.spec.containers[_].readinessProbe
}
```
**What it does:** 
- Iterates through all containers in `input.object.spec.containers`
- Checks if any container has a readiness probe defined
- Returns true if at least one container has a readiness probe

**What happens if you don't use it:**
- ❌ **Problem**: Cannot validate regular containers
- ❌ **Consequence**: Regular containers without readiness probes would be missed
- ❌ **Impact**: Policy fails to enforce readiness probes for regular containers

### Check Init Containers
```rego
hasInitContainerReadinessProbe {
    input.object.spec.template.spec.initContainers[_].readinessProbe
}
```
**What it does:** Same as above but for init containers. Init containers run before the main containers and also need readiness probes.

**What happens if you don't use it:**
- ❌ **Problem**: Init containers without readiness probes would be missed
- ❌ **Consequence**: Incomplete policy enforcement
- ❌ **Impact**: Init containers may not be properly health-checked

### Check Ephemeral Containers
```rego
hasEphemeralContainerReadinessProbe {
    input.object.spec.template.spec.ephemeralContainers[_].readinessProbe
}
```
**What it does:** Same as above but for ephemeral containers. Ephemeral containers are used for debugging and also need readiness probes.

**What happens if you don't use it:**
- ❌ **Problem**: Ephemeral containers without readiness probes would be missed
- ❌ **Consequence**: Incomplete policy enforcement
- ❌ **Impact**: Ephemeral containers may not be properly health-checked

### Pass Condition with Else Chain
```rego
result = "pass" {
    hasReadinessProbe
} else = "pass" {
    hasInitContainerReadinessProbe
} else = "pass" {
    hasEphemeralContainerReadinessProbe
}
```
**What it does:** 
- Uses an else chain to check if any container type has readiness probes
- If regular containers have readiness probes, result is "pass"
- Else if init containers have readiness probes, result is "pass"
- Else if ephemeral containers have readiness probes, result is "pass"
- If none have readiness probes, default "fail" applies

**What happens if you don't use it:**
- ❌ **Problem**: No way to determine if containers have readiness probes
- ❌ **Consequence**: Policy cannot validate readiness probe configuration
- ❌ **Impact**: Policy becomes useless

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Checking All Container Types Separately
**Why:** Different container types may have different readiness probe requirements
**Impact:** Comprehensive policy enforcement across all container types

### 3. Else Chain Pattern
**Why:** Allows policy to pass if any container type has readiness probes configured
**Impact:** Flexible validation that accepts readiness probes in any container type

### 4. Using input.object
**Why:** Wiz uses `input.object` to access the Kubernetes resource
**Impact:** Correct path for Wiz policy evaluation

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
result = "pass" {
    hasReadinessProbe
}

# ✅ CORRECT - Default result set
default result = "fail"
result = "pass" {
    hasReadinessProbe
}
```

### 2. Missing Container Type Checks
```rego
# ❌ WRONG - Only checks regular containers
hasReadinessProbe {
    input.object.spec.template.spec.containers[_].readinessProbe
}

# ✅ CORRECT - Checks all container types
hasReadinessProbe {
    input.object.spec.template.spec.containers[_].readinessProbe
}
hasInitContainerReadinessProbe {
    input.object.spec.template.spec.initContainers[_].readinessProbe
}
hasEphemeralContainerReadinessProbe {
    input.object.spec.template.spec.ephemeralContainers[_].readinessProbe
}
```

### 3. Incorrect Path for Pod
```rego
# ❌ WRONG - Wrong path (this is for Deployments)
input.object.spec.template.spec.containers[_].readinessProbe

# ✅ CORRECT - Correct path for Pods
input.object.spec.containers[_].readinessProbe
```

### 4. Missing Else Chain
```rego
# ❌ WRONG - Only checks one condition
result = "pass" {
    hasReadinessProbe
}

# ✅ CORRECT - Checks all container types with else chain
result = "pass" {
    hasReadinessProbe
} else = "pass" {
    hasInitContainerReadinessProbe
} else = "pass" {
    hasEphemeralContainerReadinessProbe
}
```

## 📊 Testing

### Test with Valid Pod
```bash
opa eval --data policies/readiness-probe-enforcement.rego \
        --input test-data/valid-pod-with-readiness.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Pod
```bash
opa eval --data policies/readiness-probe-enforcement.rego \
        --input test-data/invalid-pod-missing-readiness.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that Kubernetes Pods have readiness probes configured for at least one container type (containers, initContainers, or ephemeralContainers). The policy uses a fail-safe approach with `default result = "fail"` and comprehensively checks all container types using an else chain pattern.

