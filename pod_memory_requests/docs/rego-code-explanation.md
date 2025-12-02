# Rego Policy Code Explanation - Memory Requests Enforcement

This document provides a detailed line-by-line explanation of the Memory Requests Enforcement Rego policy for Kubernetes Pods.

## 📋 Policy Overview

The policy validates that all Kubernetes Pod containers (including initContainers and ephemeralContainers) have memory requests configured to help Kubernetes scheduler make better placement decisions.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if Pod containers have memory requests defined
# Memory requests help Kubernetes scheduler make better placement decisions
default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

# Check if all containers have memory requests defined
hasMemoryRequests {
    count({container | 
        container := input.object.spec[containerPaths[]][]
        container.resources.requests.memory
    }) == count({container | 
        container := input.object.spec[containerPaths[]][]
    })
}

result = "pass" {
    hasMemoryRequests
}

currentConfiguration := "One or more containers do not have memory requests defined"
expectedConfiguration := "All containers should have memory requests defined in resources.requests.memory"
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
- ❌ **Consequence**: Init containers and ephemeral containers without memory requests would be missed
- ❌ **Impact**: Incomplete policy enforcement

### Has Memory Requests Rule
```rego
hasMemoryRequests {
    count({container | 
        container := input.object.spec.template.spec[containerPaths[]][]
        container.resources.requests.memory
    }) == count({container | 
        container := input.object.spec.template.spec[containerPaths[]][]
    })
}
```
**What it does:** 
- Uses set comprehension to collect all containers from all container types
- First set: Counts containers that have memory requests defined
- Second set: Counts all containers (regardless of memory requests)
- Returns true if both counts are equal (meaning all containers have memory requests)

**What happens if you don't use it:**
- ❌ **Problem**: Cannot validate memory requests
- ❌ **Consequence**: Containers without memory requests would pass
- ❌ **Impact**: Policy fails to enforce memory requests

**Key Points:**
- Uses `input.object.spec[containerPaths[]][]` to iterate through all container types
- Uses set comprehension `{container | ...}` to collect containers
- Compares counts to ensure all containers have memory requests

### Pass Condition
```rego
result = "pass" {
    hasMemoryRequests
}
```
**What it does:** Sets result to "pass" if all containers have memory requests defined.

**What happens if you don't use it:**
- ❌ **Problem**: No way to pass the policy
- ❌ **Consequence**: Policy would always fail
- ❌ **Impact**: Valid deployments would be rejected

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Checking All Container Types
**Why:** All container types (containers, initContainers, ephemeralContainers) need memory requests
**Impact:** Comprehensive policy enforcement across all container types

### 3. Set Comprehension Pattern
**Why:** Efficiently compares counts of containers with memory requests vs all containers
**Impact:** Clean validation logic that ensures all containers are checked

### 4. Using input.object
**Why:** Wiz uses `input.object` to access the Kubernetes resource
**Impact:** Correct path for Wiz policy evaluation

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
hasMemoryRequests {
    count({container | ...}) == count({container | ...})
}

# ✅ CORRECT - Default result set
default result = "fail"
hasMemoryRequests {
    count({container | ...}) == count({container | ...})
}
```

### 2. Missing Container Paths Definition
```rego
# ❌ WRONG - Only checks regular containers
hasMemoryRequests {
    count({container | 
        container := input.object.spec.template.spec.containers[]
        container.resources.requests.memory
    }) == count({container | 
        container := input.object.spec.template.spec.containers[]
    })
}

# ✅ CORRECT - Checks all container types
containerPaths := {"containers", "initContainers", "ephemeralContainers"}
hasMemoryRequests {
    count({container | 
        container := input.object.spec.template.spec[containerPaths[]][]
        container.resources.requests.memory
    }) == count({container | 
        container := input.object.spec.template.spec[containerPaths[]][]
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
container.resources.requests.memory

# ✅ CORRECT - Checks limits (for limits policy)
container.resources.limits.memory
```

## 📊 Testing

### Test with Valid Pod
```bash
opa eval --data policies/memory-request-enforcement.rego \
        --input test-data/valid-pod.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Pod
```bash
opa eval --data policies/memory-request-enforcement.rego \
        --input test-data/invalid-pod-missing-memory-request.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that all containers in Kubernetes Pods have memory requests configured. The policy uses a fail-safe approach with `default result = "fail"` and comprehensively checks all container types using set comprehension to compare counts of containers with memory requests against all containers.
