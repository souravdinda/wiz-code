# Rego Policy Code Explanation - Topology Spread Constraints Enforcement

This document provides a detailed line-by-line explanation of the Topology Spread Constraints Enforcement Rego policy for Kubernetes Deployments.

## 📋 Policy Overview

The policy validates that Kubernetes Deployments with more than 2 replicas have PodTopologySpreadConstraints configured. This ensures better pod distribution across nodes, zones, or other topology domains for improved availability and resource utilization.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if Kubernetes deployments with replicas > 2 have PodTopologySpreadConstraints configured
# Workloads with multiple replicas should use topology spread constraints for better distribution

default result = "fail"

# Check if deployment has replicas > 2
hasHighReplicas if {
  input.spec.replicas > 2
}

# Check if deployment has PodTopologySpreadConstraints configured
hasTopologySpreadConstraints if {
  count(input.spec.template.spec.topologySpreadConstraints) > 0
}

result = "pass" if {
  not hasHighReplicas
}

result = "pass" if {
  hasHighReplicas
  hasTopologySpreadConstraints
}

currentConfiguration := sprintf("Deployment has %d replicas but PodTopologySpreadConstraints are not configured", [input.spec.replicas])
expectedConfiguration := "Deployments with more than 2 replicas should have PodTopologySpreadConstraints configured for better pod distribution"
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
- ❌ **Example**: A deployment with 5 replicas and no constraints might pass when it should fail

### Has High Replicas Rule
```rego
hasHighReplicas if {
  input.spec.replicas > 2
}
```
**What it does:** 
- Checks if the deployment has more than 2 replicas
- Returns true if `input.spec.replicas > 2`

**What happens if you don't use it:**
- ❌ **Problem**: Cannot determine if deployment needs topology spread constraints
- ❌ **Consequence**: Policy cannot differentiate between deployments that need constraints and those that don't
- ❌ **Impact**: All deployments would be treated the same, regardless of replica count
- ❌ **Example**: A deployment with 1 replica would be required to have constraints unnecessarily

**Key Points:**
- Uses `input.spec.replicas` to access the replica count
- The `> 2` condition identifies deployments that need constraints

### Has Topology Spread Constraints Rule
```rego
hasTopologySpreadConstraints if {
  count(input.spec.template.spec.topologySpreadConstraints) > 0
}
```
**What it does:** 
- Checks if the deployment has PodTopologySpreadConstraints configured
- Uses `count()` to check if the `topologySpreadConstraints` array has any elements
- Returns true if at least one topology spread constraint is configured

**What happens if you don't use it:**
- ❌ **Problem**: Cannot verify if constraints are configured
- ❌ **Consequence**: Policy cannot validate constraint presence
- ❌ **Impact**: Policy fails to enforce topology spread constraints
- ❌ **Example**: A deployment with 5 replicas but no constraints would pass when it should fail

**Key Points:**
- Uses `input.spec.template.spec.topologySpreadConstraints` to access constraints
- The `count() > 0` check ensures at least one constraint exists

### First Pass Condition
```rego
result = "pass" if {
  not hasHighReplicas
}
```
**What it does:** 
- Sets result to "pass" if the deployment does NOT have high replicas (replicas <= 2)
- This allows deployments with 2 or fewer replicas to pass without requiring constraints

**What happens if you don't use it:**
- ❌ **Problem**: Deployments with low replica counts would fail unnecessarily
- ❌ **Consequence**: All deployments would be required to have constraints, even those with 1-2 replicas
- ❌ **Impact**: Overly strict policy that rejects valid deployments
- ❌ **Example**: A deployment with 2 replicas would fail even though constraints aren't needed

**Key Points:**
- Uses `not hasHighReplicas` to check for low replica counts
- Allows deployments with 2 or fewer replicas to pass

### Second Pass Condition
```rego
result = "pass" if {
  hasHighReplicas
  hasTopologySpreadConstraints
}
```
**What it does:** 
- Sets result to "pass" if the deployment has high replicas AND has topology spread constraints configured
- This ensures deployments with more than 2 replicas have the required constraints

**What happens if you don't use it:**
- ❌ **Problem**: No way for high-replica deployments to pass
- ❌ **Consequence**: All deployments with more than 2 replicas would fail, even if they have constraints
- ❌ **Impact**: Valid deployments with constraints would be rejected
- ❌ **Example**: A deployment with 5 replicas and proper constraints would fail

**Key Points:**
- Requires both conditions: high replicas AND constraints
- Ensures deployments needing constraints actually have them

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Two Pass Conditions
**Why:** Different logic for low-replica vs high-replica deployments
**Impact:** Flexible policy that only enforces constraints when needed

### 3. Replica Count Threshold (> 2)
**Why:** Deployments with 2 or fewer replicas don't need topology spread constraints
**Impact:** Reduces unnecessary requirements while ensuring proper distribution for larger deployments

### 4. Using input.spec (not input.object.spec)
**Why:** This policy uses `input.spec` directly for the resource specification
**Impact:** Correct path for this specific policy pattern

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
hasHighReplicas if {
  input.spec.replicas > 2
}

# ✅ CORRECT - Default result set
default result = "fail"
hasHighReplicas if {
  input.spec.replicas > 2
}
```

### 2. Missing First Pass Condition
```rego
# ❌ WRONG - Low-replica deployments would fail
result = "pass" if {
  hasHighReplicas
  hasTopologySpreadConstraints
}

# ✅ CORRECT - Allow low-replica deployments to pass
result = "pass" if {
  not hasHighReplicas
}
result = "pass" if {
  hasHighReplicas
  hasTopologySpreadConstraints
}
```

### 3. Incorrect Replica Check
```rego
# ❌ WRONG - Uses >= instead of >
hasHighReplicas if {
  input.spec.replicas >= 2
}

# ✅ CORRECT - Uses > to allow 2 replicas without constraints
hasHighReplicas if {
  input.spec.replicas > 2
}
```

### 4. Missing Constraint Check
```rego
# ❌ WRONG - Doesn't check if constraints exist
result = "pass" if {
  hasHighReplicas
}

# ✅ CORRECT - Checks both high replicas and constraints
result = "pass" if {
  hasHighReplicas
  hasTopologySpreadConstraints
}
```

## 📊 Testing

### Test with Valid Deployment (High Replicas + Constraints)
```bash
opa eval --data policies/topology-spread-constraints-enforcement.rego \
        --input test-data/valid-deployment-with-constraints.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Valid Deployment (Low Replicas)
```bash
opa eval --data policies/topology-spread-constraints-enforcement.rego \
        --input test-data/valid-deployment-low-replicas.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Deployment (High Replicas, No Constraints)
```bash
opa eval --data policies/topology-spread-constraints-enforcement.rego \
        --input test-data/invalid-deployment-missing-constraints.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that Kubernetes Deployments with more than 2 replicas have PodTopologySpreadConstraints configured. The policy uses a fail-safe approach with `default result = "fail"` and implements two pass conditions: one for low-replica deployments (which don't need constraints) and one for high-replica deployments (which must have constraints). This provides flexible enforcement that only requires constraints when they're actually needed for proper pod distribution.

