# Rego Policy Code Explanation - Minimum Replicas Enforcement

This document provides a detailed line-by-line explanation of the Minimum Replicas Enforcement Rego policy for Kubernetes StatefulSets.

## 📋 Policy Overview

The policy validates that all Kubernetes StatefulSets have at least 2 replicas configured for high availability. StatefulSets with fewer than 2 replicas are not highly available and can cause service unavailability if a single pod fails.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if Kubernetes statefulsets have at least 2 replicas for high availability
# StatefulSets with fewer than 2 replicas are not highly available

default result = "fail"

# Check if statefulset has at least 2 replicas
hasMinimumReplicas if {
  input.spec.replicas >= 2
}

result = "pass" if {
  hasMinimumReplicas
}

currentConfiguration := sprintf("StatefulSet has %d replicas, which is less than the minimum of 2 for high availability", [input.spec.replicas])
expectedConfiguration := "StatefulSets should have at least 2 replicas configured for high availability"
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
- ❌ **Example**: A statefulset with 1 replica might pass when it should fail

### Has Minimum Replicas Rule
```rego
hasMinimumReplicas if {
  input.spec.replicas >= 2
}
```
**What it does:** 
- Checks if the statefulset has at least 2 replicas
- Returns true if `input.spec.replicas >= 2`
- Uses the `>=` operator to include statefulsets with exactly 2 replicas

**What happens if you don't use it:**
- ❌ **Problem**: Cannot validate replica count
- ❌ **Consequence**: Policy cannot determine if statefulset meets minimum replica requirement
- ❌ **Impact**: Policy fails to enforce high availability requirements
- ❌ **Example**: A statefulset with 1 replica would pass when it should fail

**Key Points:**
- Uses `input.spec.replicas` to access the replica count
- The `>= 2` condition ensures at least 2 replicas for high availability
- Includes statefulsets with exactly 2 replicas (meets minimum requirement)

### Pass Condition
```rego
result = "pass" if {
  hasMinimumReplicas
}
```
**What it does:** 
- Sets result to "pass" if the statefulset has at least 2 replicas
- Only passes when `hasMinimumReplicas` is true

**What happens if you don't use it:**
- ❌ **Problem**: No way for valid statefulsets to pass
- ❌ **Consequence**: All statefulsets would fail, even those with 2+ replicas
- ❌ **Impact**: Valid statefulsets would be rejected
- ❌ **Example**: A statefulset with 3 replicas would fail even though it meets requirements

**Key Points:**
- Simple condition: only checks if minimum replicas are met
- No additional conditions needed for this policy

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Minimum of 2 Replicas
**Why:** 2 replicas is the minimum for high availability (allows one pod to fail while maintaining service)
**Impact:** Ensures statefulsets can survive single pod failures

### 3. Using >= (not >)
**Why:** Includes statefulsets with exactly 2 replicas (meets minimum requirement)
**Impact:** Correctly validates that 2 replicas is acceptable

### 4. Using input.spec (not input.object.spec)
**Why:** This policy uses `input.spec` directly for the resource specification
**Impact:** Correct path for this specific policy pattern

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
hasMinimumReplicas if {
  input.spec.replicas >= 2
}

# ✅ CORRECT - Default result set
default result = "fail"
hasMinimumReplicas if {
  input.spec.replicas >= 2
}
```

### 2. Wrong Comparison Operator
```rego
# ❌ WRONG - Uses > instead of >=
hasMinimumReplicas if {
  input.spec.replicas > 2
}

# ✅ CORRECT - Uses >= to include 2 replicas
hasMinimumReplicas if {
  input.spec.replicas >= 2
}
```

### 3. Missing Pass Condition
```rego
# ❌ WRONG - No way to pass
default result = "fail"
hasMinimumReplicas if {
  input.spec.replicas >= 2
}

# ✅ CORRECT - Pass condition defined
default result = "fail"
hasMinimumReplicas if {
  input.spec.replicas >= 2
}
result = "pass" if {
  hasMinimumReplicas
}
```

### 4. Incorrect Replica Path
```rego
# ❌ WRONG - Wrong path
hasMinimumReplicas if {
  input.replicas >= 2
}

# ✅ CORRECT - Correct path
hasMinimumReplicas if {
  input.spec.replicas >= 2
}
```

## 📊 Testing

### Test with Valid StatefulSet (2+ Replicas)
```bash
opa eval --data policies/min-replicas-enforcement.rego \
        --input test-data/valid-statefulset.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid StatefulSet (< 2 Replicas)
```bash
opa eval --data policies/min-replicas-enforcement.rego \
        --input test-data/invalid-statefulset.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that all Kubernetes StatefulSets have at least 2 replicas configured for high availability. The policy uses a fail-safe approach with `default result = "fail"` and validates that `input.spec.replicas >= 2`. This simple but effective policy prevents statefulsets from being created with insufficient replicas, ensuring they can survive single pod failures and maintain service availability.

