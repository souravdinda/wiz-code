# Rego Policy Code Explanation - PDB Replica Validation

This document provides a detailed line-by-line explanation of the PDB Replica Validation Rego policy for Kubernetes Deployments.

## 📋 Policy Overview

The policy validates that deployments with replicas <= 1 do not have PodDisruptionBudget (PDB) configured. Deployments with only 1 replica should not have PDB as it prevents disruption and requires at least 2 replicas to allow for pod disruption while maintaining availability.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if deployments with replicas <= 1 have PDB configured
# Deployments with only 1 replica should not have PDB as it prevents disruption

default result = "fail"

# Check if deployment has replicas <= 1
hasLowReplicas if {
  input.spec.replicas <= 1
}

# Check if PDB exists (via annotation or assume it exists)
hasPDB if {
  input.metadata.annotations["pdb-exists"] == "true"
}

# Deny if replicas <= 1 AND PDB exists
result = "pass" if {
  not hasLowReplicas
}

result = "pass" if {
  hasLowReplicas
  not hasPDB
}

currentConfiguration := sprintf("Deployment has %d replicas but PDB exists or is being created", [input.spec.replicas])
expectedConfiguration := "Deployments with replicas <= 1 should not have PodDisruptionBudget configured"
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
- ❌ **Example**: A deployment with 1 replica and PDB might pass when it should fail

### Has Low Replicas Rule
```rego
hasLowReplicas if {
  input.spec.replicas <= 1
}
```
**What it does:** 
- Checks if the deployment has 1 or fewer replicas
- Returns true if `input.spec.replicas <= 1`
- Uses the `<=` operator to include deployments with exactly 1 replica

**What happens if you don't use it:**
- ❌ **Problem**: Cannot determine if deployment has low replica count
- ❌ **Consequence**: Policy cannot identify deployments that shouldn't have PDB
- ❌ **Impact**: Policy fails to enforce the rule
- ❌ **Example**: A deployment with 1 replica and PDB would pass when it should fail

**Key Points:**
- Uses `input.spec.replicas` to access the replica count
- The `<= 1` condition identifies deployments that shouldn't have PDB
- Includes deployments with exactly 1 replica

### Has PDB Rule
```rego
hasPDB if {
  input.metadata.annotations["pdb-exists"] == "true"
}
```
**What it does:** 
- Checks if PDB exists by looking for the `pdb-exists` annotation
- Returns true if the annotation exists and is set to "true"

**What happens if you don't use it:**
- ❌ **Problem**: Cannot determine if PDB is configured
- ❌ **Consequence**: Policy cannot validate PDB presence
- ❌ **Impact**: Policy fails to enforce the rule
- ❌ **Example**: A deployment with 1 replica and PDB would pass when it should fail

**Key Points:**
- Uses `input.metadata.annotations` to access annotations
- Checks for specific annotation key `pdb-exists`
- In a real environment, PDB existence would be checked by querying PDB resources separately

### First Pass Condition (Not Low Replicas)
```rego
result = "pass" if {
  not hasLowReplicas
}
```
**What it does:** 
- Sets result to "pass" if the deployment does NOT have low replicas (replicas > 1)
- This allows deployments with 2+ replicas to pass (they can have PDB)

**What happens if you don't use it:**
- ❌ **Problem**: Deployments with 2+ replicas would fail unnecessarily
- ❌ **Consequence**: All deployments would be validated, even those that can have PDB
- ❌ **Impact**: Overly strict policy that rejects valid deployments
- ❌ **Example**: A deployment with 3 replicas and PDB would fail even though it's valid

**Key Points:**
- Uses `not hasLowReplicas` to check for high replica counts
- Allows deployments with 2+ replicas to pass

### Second Pass Condition (Low Replicas, No PDB)
```rego
result = "pass" if {
  hasLowReplicas
  not hasPDB
}
```
**What it does:** 
- Sets result to "pass" if the deployment has low replicas AND no PDB exists
- This allows deployments with 1 replica to pass if they don't have PDB

**What happens if you don't use it:**
- ❌ **Problem**: Deployments with 1 replica and no PDB would fail
- ❌ **Consequence**: Valid deployments would be rejected
- ❌ **Impact**: Overly strict policy that rejects valid deployments
- ❌ **Example**: A deployment with 1 replica and no PDB would fail unnecessarily

**Key Points:**
- Requires both conditions: low replicas AND no PDB
- Allows deployments with 1 replica to pass if they don't have PDB

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Two Pass Conditions
**Why:** Different logic for high-replica vs low-replica deployments
**Impact:** Flexible policy that only enforces the rule when needed

### 3. Replica Count Threshold (<= 1)
**Why:** Deployments with 1 or fewer replicas should not have PDB
**Impact:** Prevents PDB from blocking disruption when there's only one pod

### 4. Using Annotation for PDB Detection
**Why:** Simple way to detect PDB configuration without querying separate resources
**Impact:** Self-contained policy that works with deployment resource alone

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
hasLowReplicas if {
  input.spec.replicas <= 1
}

# ✅ CORRECT - Default result set
default result = "fail"
hasLowReplicas if {
  input.spec.replicas <= 1
}
```

### 2. Missing First Pass Condition
```rego
# ❌ WRONG - High-replica deployments would fail
result = "pass" if {
  hasLowReplicas
  not hasPDB
}

# ✅ CORRECT - Allow high-replica deployments to pass
result = "pass" if {
  not hasLowReplicas
}
result = "pass" if {
  hasLowReplicas
  not hasPDB
}
```

### 3. Wrong Replica Check
```rego
# ❌ WRONG - Uses < instead of <=
hasLowReplicas if {
  input.spec.replicas < 1
}

# ✅ CORRECT - Uses <= to include 1 replica
hasLowReplicas if {
  input.spec.replicas <= 1
}
```

### 4. Missing Second Pass Condition
```rego
# ❌ WRONG - Low-replica deployments without PDB would fail
result = "pass" if {
  not hasLowReplicas
}

# ✅ CORRECT - Allow low-replica deployments without PDB to pass
result = "pass" if {
  not hasLowReplicas
}
result = "pass" if {
  hasLowReplicas
  not hasPDB
}
```

## 📊 Testing

### Test with Valid Deployment (High Replicas)
```bash
opa eval --data policies/pdb-replica-validation.rego \
        --input test-data/valid-deployment-high-replicas.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Valid Deployment (Low Replicas, No PDB)
```bash
opa eval --data policies/pdb-replica-validation.rego \
        --input test-data/valid-deployment-low-replicas-no-pdb.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Deployment (Low Replicas, Has PDB)
```bash
opa eval --data policies/pdb-replica-validation.rego \
        --input test-data/invalid-deployment-low-replicas-pdb.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that deployments with replicas <= 1 do not have PodDisruptionBudget configured. The policy uses a fail-safe approach with `default result = "fail"` and implements two pass conditions: one for deployments with 2+ replicas (which can have PDB) and one for deployments with 1 replica that don't have PDB. This prevents PDB from being configured on single-replica deployments, which would block disruption and prevent proper pod management.

