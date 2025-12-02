# Rego Policy Code Explanation - Liveness Probes Enforcement

This document provides a detailed line-by-line explanation of the Liveness Probes Enforcement Rego policy for Kubernetes DaemonSets.

## 📋 Policy Overview

The policy validates that all Kubernetes DaemonSet containers (including initContainers and ephemeralContainers) have liveness probes configured to ensure containers are restarted when they become unhealthy.

## 🔍 Complete Policy Code

```rego
package wiz

default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

result = "pass" {
  input.spec.template.spec[containerPaths[]][].livenessProbe
}

currentConfiguration := "DaemonSet containers do not have livenessProbe configured"
expectedConfiguration := "DaemonSet containers should have livenessProbe configured to ensure container health monitoring"
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
- ❌ **Consequence**: Init containers and ephemeral containers without liveness probes would be missed
- ❌ **Impact**: Incomplete policy enforcement

### Pass Condition
```rego
result = "pass" {
  input.spec.template.spec[containerPaths[]][].livenessProbe
}
```
**What it does:** 
- Uses the `containerPaths[]` syntax to iterate through all container types
- Checks if all containers across all types have liveness probes defined
- Returns "pass" only if every container in every container type has a liveness probe

**What happens if you don't use it:**
- ❌ **Problem**: Cannot validate liveness probe configuration
- ❌ **Consequence**: Containers without liveness probes would pass
- ❌ **Impact**: Policy fails to enforce liveness probes

**Note:** The `containerPaths[]` syntax is a Wiz-specific extension that expands to check all container types simultaneously.

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Checking All Container Types
**Why:** All container types (containers, initContainers, ephemeralContainers) need liveness probes
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
  input.spec.template.spec[containerPaths[]][].livenessProbe
}

# ✅ CORRECT - Default result set
default result = "fail"
result = "pass" {
  input.spec.template.spec[containerPaths[]][].livenessProbe
}
```

### 2. Missing Container Paths Definition
```rego
# ❌ WRONG - No container paths defined
result = "pass" {
  input.spec.template.spec.containers[].livenessProbe
}

# ✅ CORRECT - Container paths defined
containerPaths := {"containers", "initContainers", "ephemeralContainers"}
result = "pass" {
  input.spec.template.spec[containerPaths[]][].livenessProbe
}
```

### 3. Incorrect Path for Deployment
```rego
# ❌ WRONG - Wrong path (this is for Pods)
input.spec[containerPaths[]][].livenessProbe

# ✅ CORRECT - Correct path for Deployments
input.spec.template.spec[containerPaths[]][].livenessProbe
```

### 4. Missing Container Types
```rego
# ❌ WRONG - Only checks regular containers
containerPaths := {"containers"}

# ✅ CORRECT - Checks all container types
containerPaths := {"containers", "initContainers", "ephemeralContainers"}
```

## 📊 Testing

### Test with Valid DaemonSet
```bash
opa eval --data policies/probes-enforcement.rego \
        --input test-data/valid-daemonset-with-probes.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid DaemonSet
```bash
opa eval --data policies/probes-enforcement.rego \
        --input test-data/invalid-daemonset-missing-liveness.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that all containers in Kubernetes DaemonSets have liveness probes configured. The policy uses a fail-safe approach with `default result = "fail"` and comprehensively checks all container types using the `containerPaths[]` syntax, which is a Wiz-specific extension that efficiently validates all container types in a single expression.
