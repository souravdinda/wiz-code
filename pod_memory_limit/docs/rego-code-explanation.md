# Rego Policy Code Explanation - Memory Limits Enforcement

This document provides a detailed line-by-line explanation of the Memory Limits Enforcement Rego policy for Kubernetes Pods.

## 📋 Policy Overview

The policy validates that all Kubernetes Pod containers (including initContainers and ephemeralContainers) have memory limits configured to prevent resource contention and unpredictable performance.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if Pod containers have memory limits defined
# Memory limits help prevent resource contention and unpredictable performance
default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

# Check if all containers have memory limits defined
hasMemoryLimits {
    count({container | 
        container := input.object.spec[containerPaths[]][]
        container.resources.limits.memory
    }) == count({container | 
        container := input.object.spec[containerPaths[]][]
    })
}

result = "pass" {
    hasMemoryLimits
}

currentConfiguration := "One or more containers do not have memory limits defined"
expectedConfiguration := "All containers should have memory limits defined in resources.limits.memory"
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
- ❌ **Consequence**: Init containers and ephemeral containers without memory limits would be missed
- ❌ **Impact**: Incomplete policy enforcement

### Has Memory Limits Rule
```rego
hasMemoryLimits {
    count({container | 
        container := input.object.spec[containerPaths[]][]
        container.resources.limits.memory
    }) == count({container | 
        container := input.object.spec[containerPaths[]][]
    })
}
```
**What it does:** 
- Uses set comprehension to collect all containers from all container types
- First set: Counts containers that have memory limits defined
- Second set: Counts all containers (regardless of memory limits)
- Returns true if both counts are equal (meaning all containers have memory limits)

**What happens if you don't use it:**
- ❌ **Problem**: Cannot validate memory limits
- ❌ **Consequence**: Containers without memory limits would pass
- ❌ **Impact**: Policy fails to enforce memory limits

**Key Points:**
- Uses `input.object.spec[containerPaths[]][]` to iterate through all container types
- Uses set comprehension `{container | ...}` to collect containers
- Compares counts to ensure all containers have memory limits

### Pass Condition
```rego
result = "pass" {
    hasMemoryLimits
}
```
**What it does:** Sets result to "pass" if all containers have memory limits defined.

**What happens if you don't use it:**
- ❌ **Problem**: No way to pass the policy
- ❌ **Consequence**: Policy would always fail
- ❌ **Impact**: Valid deployments would be rejected

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Checking All Container Types
**Why:** All container types (containers, initContainers, ephemeralContainers) need memory limits
**Impact:** Comprehensive policy enforcement across all container types

### 3. Set Comprehension Pattern
**Why:** Efficiently compares counts of containers with memory limits vs all containers
**Impact:** Clean validation logic that ensures all containers are checked

### 4. Using input.object
**Why:** Wiz uses `input.object` to access the Kubernetes resource
**Impact:** Correct path for Wiz policy evaluation

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
hasMemoryLimits {
    count({container | ...}) == count({container | ...})
}

# ✅ CORRECT - Default result set
default result = "fail"
hasMemoryLimits {
    count({container | ...}) == count({container | ...})
}
```

### 2. Missing Container Paths Definition
```rego
# ❌ WRONG - Only checks regular containers
hasMemoryLimits {
    count({container | 
        container := input.object.spec.containers[]
        container.resources.limits.memory
    }) == count({container | 
        container := input.object.spec.containers[]
    })
}

# ✅ CORRECT - Checks all container types
containerPaths := {"containers", "initContainers", "ephemeralContainers"}
hasMemoryLimits {
    count({container | 
        container := input.object.spec[containerPaths[]][]
        container.resources.limits.memory
    }) == count({container | 
        container := input.object.spec[containerPaths[]][]
    })
}
```

### 3. Incorrect Path for Pod
```rego
# ❌ WRONG - Wrong path (this is for Deployments)
container := input.object.spec.template.spec[containerPaths[]][]

# ✅ CORRECT - Correct path for Pods
container := input.object.spec[containerPaths[]][]
```

### 4. Wrong Resource Path
```rego
# ❌ WRONG - Checks requests instead of limits (for limits policy)
container.resources.limits.memory

# ✅ CORRECT - Checks limits (for limits policy)
container.resources.limits.memory
```

## 📊 Testing

### Test with Valid Pod
```bash
opa eval --data policies/memory-limit-enforcement.rego \
        --input test-data/valid-pod.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Pod
```bash
opa eval --data policies/memory-limit-enforcement.rego \
        --input test-data/invalid-pod-missing-memory-limit.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that all containers in Kubernetes Pods have memory limits configured. The policy uses a fail-safe approach with `default result = "fail"` and comprehensively checks all container types using set comprehension to compare counts of containers with memory limits against all containers.
