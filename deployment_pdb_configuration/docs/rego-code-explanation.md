# Rego Policy Code Explanation - PDB Configuration Enforcement

This document provides a detailed line-by-line explanation of the PDB Configuration Enforcement Rego policy for Kubernetes Deployments.

## 📋 Policy Overview

The policy validates that Kubernetes deployments with replicas <= 2 have PodDisruptionBudget (PDB) configured. Deployments with 2 or fewer replicas should have PDB to prevent disruption during maintenance or node drains.

## 🔍 Complete Policy Code

```rego
package wiz

# This rule checks if Kubernetes deployments with replicas <= 2 have PodDisruptionBudget configured
# Deployments with 2 or fewer replicas should have PDB to prevent disruption

default result = "fail"

# Check if deployment has replicas <= 2
hasLowReplicas if {
  input.spec.replicas <= 2
}

# Check if PDB is configured (via annotation)
hasPDB if {
  input.metadata.annotations["pdb-configured"] == "true"
}

result = "pass" if {
  not hasLowReplicas
}

result = "pass" if {
  hasLowReplicas
  hasPDB
}

currentConfiguration := sprintf("Deployment has %d replicas but PodDisruptionBudget is not configured", [input.spec.replicas])
expectedConfiguration := "Deployments with replicas <= 2 should have PodDisruptionBudget configured to prevent disruption"
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
- ❌ **Example**: A deployment with 2 replicas but no PDB might pass when it should fail

### Has Low Replicas Rule
```rego
hasLowReplicas if {
  input.spec.replicas <= 2
}
```
**What it does:** 
- Checks if the deployment has 2 or fewer replicas
- Returns true if `input.spec.replicas <= 2`
- Uses the `<=` operator to include deployments with exactly 2 replicas

**What happens if you don't use it:**
- ❌ **Problem**: Cannot determine if deployment needs PDB
- ❌ **Consequence**: Policy cannot differentiate between deployments that need PDB and those that don't
- ❌ **Impact**: Policy fails to enforce PDB requirement
- ❌ **Example**: A deployment with 2 replicas but no PDB would pass when it should fail

**Key Points:**
- Uses `input.spec.replicas` to access the replica count
- The `<= 2` condition identifies deployments that need PDB
- Includes deployments with exactly 2 replicas

### Has PDB Rule
```rego
hasPDB if {
  input.metadata.annotations["pdb-configured"] == "true"
}
```
**What it does:** 
- Checks if PDB is configured by looking for the `pdb-configured` annotation
- Returns true if the annotation exists and is set to "true"

**What happens if you don't use it:**
- ❌ **Problem**: Cannot verify if PDB is configured
- ❌ **Consequence**: Policy cannot validate PDB presence
- ❌ **Impact**: Policy fails to enforce PDB requirement
- ❌ **Example**: A deployment with 2 replicas but no PDB would pass when it should fail

**Key Points:**
- Uses `input.metadata.annotations` to access annotations
- Checks for specific annotation key `pdb-configured`
- In a real environment, PDB existence would be checked by querying PDB resources separately

### First Pass Condition (Not Low Replicas)
```rego
result = "pass" if {
  not hasLowReplicas
}
```
**What it does:** 
- Sets result to "pass" if the deployment does NOT have low replicas (replicas > 2)
- This allows deployments with 3+ replicas to pass without requiring PDB

**What happens if you don't use it:**
- ❌ **Problem**: Deployments with 3+ replicas would fail unnecessarily
- ❌ **Consequence**: All deployments would be required to have PDB, even those with many replicas
- ❌ **Impact**: Overly strict policy that rejects valid deployments
- ❌ **Example**: A deployment with 5 replicas would fail even though PDB isn't strictly required

**Key Points:**
- Uses `not hasLowReplicas` to check for high replica counts
- Allows deployments with 3+ replicas to pass

### Second Pass Condition (Low Replicas, Has PDB)
```rego
result = "pass" if {
  hasLowReplicas
  hasPDB
}
```
**What it does:** 
- Sets result to "pass" if the deployment has low replicas AND PDB is configured
- This ensures deployments with 2 or fewer replicas have the required PDB

**What happens if you don't use it:**
- ❌ **Problem**: No way for low-replica deployments to pass
- ❌ **Consequence**: All deployments with 2 or fewer replicas would fail, even if they have PDB
- ❌ **Impact**: Valid deployments with PDB would be rejected
- ❌ **Example**: A deployment with 2 replicas and proper PDB would fail

**Key Points:**
- Requires both conditions: low replicas AND PDB
- Ensures deployments needing PDB actually have it

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Two Pass Conditions
**Why:** Different logic for high-replica vs low-replica deployments
**Impact:** Flexible policy that only enforces PDB when needed

### 3. Replica Count Threshold (<= 2)
**Why:** Deployments with 2 or fewer replicas should have PDB to prevent disruption
**Impact:** Ensures small deployments are protected during maintenance

### 4. Using Annotation for PDB Detection
**Why:** Simple way to detect PDB configuration without querying separate resources
**Impact:** Self-contained policy that works with deployment resource alone

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
hasLowReplicas if {
  input.spec.replicas <= 2
}

# ✅ CORRECT - Default result set
default result = "fail"
hasLowReplicas if {
  input.spec.replicas <= 2
}
```

### 2. Missing First Pass Condition
```rego
# ❌ WRONG - High-replica deployments would fail
result = "pass" if {
  hasLowReplicas
  hasPDB
}

# ✅ CORRECT - Allow high-replica deployments to pass
result = "pass" if {
  not hasLowReplicas
}
result = "pass" if {
  hasLowReplicas
  hasPDB
}
```

### 3. Wrong Replica Check
```rego
# ❌ WRONG - Uses < instead of <=
hasLowReplicas if {
  input.spec.replicas < 2
}

# ✅ CORRECT - Uses <= to include 2 replicas
hasLowReplicas if {
  input.spec.replicas <= 2
}
```

### 4. Missing Second Pass Condition
```rego
# ❌ WRONG - Low-replica deployments with PDB would fail
result = "pass" if {
  not hasLowReplicas
}

# ✅ CORRECT - Allow low-replica deployments with PDB to pass
result = "pass" if {
  not hasLowReplicas
}
result = "pass" if {
  hasLowReplicas
  hasPDB
}
```

## 📊 Testing

### Test with Valid Deployment (High Replicas)
```bash
opa eval --data policies/pdb-configuration-enforcement.rego \
        --input test-data/valid-deployment-high-replicas.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Valid Deployment (Low Replicas, Has PDB)
```bash
opa eval --data policies/pdb-configuration-enforcement.rego \
        --input test-data/valid-deployment-low-replicas-pdb.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Deployment (Low Replicas, No PDB)
```bash
opa eval --data policies/pdb-configuration-enforcement.rego \
        --input test-data/invalid-deployment-low-replicas-no-pdb.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that Kubernetes deployments with replicas <= 2 have PodDisruptionBudget configured. The policy uses a fail-safe approach with `default result = "fail"` and implements two pass conditions: one for deployments with 3+ replicas (which don't strictly need PDB) and one for deployments with 2 or fewer replicas that have PDB configured. This ensures small deployments are protected during maintenance or node drains, preventing service disruption.

