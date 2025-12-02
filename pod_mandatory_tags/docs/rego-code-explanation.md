# Rego Policy Code Explanation - Mandatory Tags Enforcement

This document provides a detailed line-by-line explanation of the Mandatory Tags Enforcement Rego policy for Kubernetes Pods.

## 📋 Policy Overview

The policy validates that all Kubernetes Pod resources have mandatory labels (`environment`, `owner`, `project`, `team`) configured with non-empty values. This ensures proper resource tagging for governance, cost allocation, and compliance.

## 🔍 Complete Policy Code

```rego
package wiz

# This Cloud Configuration Rule checks if Kubernetes deployments have mandatory tags/labels configured

default result = "fail"

mandatoryLabels := {"environment", "owner", "project", "team"}

# Check if all mandatory labels are present
allMandatoryLabelsPresent {
  count({label | mandatoryLabels[label]; input.metadata.labels[label]}) == count(mandatoryLabels)
}

# Check if all mandatory labels have non-empty values
allMandatoryLabelsHaveValues {
  count({label | mandatoryLabels[label]; input.metadata.labels[label] != ""}) == count(mandatoryLabels)
}

result = "pass" {
  allMandatoryLabelsPresent
  allMandatoryLabelsHaveValues
}

currentConfiguration := sprintf("Pod is missing mandatory labels or has empty values. Present labels: %v", [input.metadata.labels])
expectedConfiguration := sprintf("Pod should have all mandatory labels with non-empty values: %v", [mandatoryLabels])
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

### Mandatory Labels Definition
```rego
mandatoryLabels := {"environment", "owner", "project", "team"}
```
**What it does:** Defines the set of mandatory labels that must be present on the resource.

**What happens if you don't use it:**
- ❌ **Problem**: No way to define which labels are required
- ❌ **Consequence**: Policy cannot validate labels
- ❌ **Impact**: Policy fails to enforce mandatory tags

### All Mandatory Labels Present Rule
```rego
allMandatoryLabelsPresent {
  count({label | mandatoryLabels[label]; input.metadata.labels[label]}) == count(mandatoryLabels)
}
```
**What it does:** 
- Uses set comprehension to collect labels that are both in `mandatoryLabels` and present in `input.metadata.labels`
- Compares the count of present mandatory labels with the total count of mandatory labels
- Returns true only if all mandatory labels are present

**What happens if you don't use it:**
- ❌ **Problem**: Cannot check if all labels are present
- ❌ **Consequence**: Resources missing labels would pass
- ❌ **Impact**: Policy fails to enforce label presence

**Key Points:**
- Uses set comprehension `{label | ...}` to filter labels
- Checks `mandatoryLabels[label]` to ensure label is in the mandatory set
- Checks `input.metadata.labels[label]` to ensure label exists in the resource

### All Mandatory Labels Have Values Rule
```rego
allMandatoryLabelsHaveValues {
  count({label | mandatoryLabels[label]; input.metadata.labels[label] != ""}) == count(mandatoryLabels)
}
```
**What it does:** 
- Uses set comprehension to collect labels that are mandatory and have non-empty values
- Compares the count of mandatory labels with non-empty values with the total count
- Returns true only if all mandatory labels have non-empty values

**What happens if you don't use it:**
- ❌ **Problem**: Cannot check if labels have values
- ❌ **Consequence**: Resources with empty label values would pass
- ❌ **Impact**: Policy fails to enforce non-empty label values

**Key Points:**
- Checks `input.metadata.labels[label] != ""` to ensure label value is not empty
- Ensures all mandatory labels have meaningful values

### Pass Condition
```rego
result = "pass" {
  allMandatoryLabelsPresent
  allMandatoryLabelsHaveValues
}
```
**What it does:** Sets result to "pass" only if both conditions are met: all mandatory labels are present AND all have non-empty values.

**What happens if you don't use it:**
- ❌ **Problem**: No way to pass the policy
- ❌ **Consequence**: Policy would always fail
- ❌ **Impact**: Valid deployments would be rejected

## 🎯 Key Design Decisions

### 1. Default Result to "fail"
**Why:** Fail-safe approach - assumes non-compliance unless proven otherwise
**Impact:** Ensures strict enforcement and prevents accidental approvals

### 2. Two-Step Validation
**Why:** Separates checking label presence from checking label values
**Impact:** Clear validation logic that's easy to understand and maintain

### 3. Set Comprehension Pattern
**Why:** Efficiently counts matching labels using set operations
**Impact:** Clean, declarative validation logic

### 4. Using input.metadata (not input.object.metadata)
**Why:** This policy uses `input.metadata` directly for the resource metadata
**Impact:** Correct path for this specific policy pattern

## 🚨 Common Mistakes to Avoid

### 1. Missing Default Result
```rego
# ❌ WRONG - No default result
allMandatoryLabelsPresent {
  count({label | mandatoryLabels[label]; input.metadata.labels[label]}) == count(mandatoryLabels)
}

# ✅ CORRECT - Default result set
default result = "fail"
allMandatoryLabelsPresent {
  count({label | mandatoryLabels[label]; input.metadata.labels[label]}) == count(mandatoryLabels)
}
```

### 2. Not Checking for Empty Values
```rego
# ❌ WRONG - Only checks presence, not values
result = "pass" {
  allMandatoryLabelsPresent
}

# ✅ CORRECT - Checks both presence and non-empty values
result = "pass" {
  allMandatoryLabelsPresent
  allMandatoryLabelsHaveValues
}
```

### 3. Incorrect Path for Metadata
```rego
# ❌ WRONG - Wrong path
input.object.metadata.labels[label]

# ✅ CORRECT - Correct path
input.metadata.labels[label]
```

### 4. Missing Set Comprehension
```rego
# ❌ WRONG - Doesn't use set comprehension
allMandatoryLabelsPresent {
  input.metadata.labels.environment
  input.metadata.labels.owner
  input.metadata.labels.project
  input.metadata.labels.team
}

# ✅ CORRECT - Uses set comprehension for flexibility
allMandatoryLabelsPresent {
  count({label | mandatoryLabels[label]; input.metadata.labels[label]}) == count(mandatoryLabels)
}
```

## 📊 Testing

### Test with Valid Pod
```bash
opa eval --data policies/mandatory-tags-enforcement.rego \
        --input test-data/valid-deployment.json \
        "data.wiz.result"
# Expected: "pass"
```

### Test with Invalid Pod (Missing Labels)
```bash
opa eval --data policies/mandatory-tags-enforcement.rego \
        --input test-data/invalid-deployment-missing-labels.json \
        "data.wiz.result"
# Expected: "fail"
```

### Test with Invalid Pod (Empty Values)
```bash
opa eval --data policies/mandatory-tags-enforcement.rego \
        --input test-data/invalid-deployment-empty-label-values.json \
        "data.wiz.result"
# Expected: "fail"
```

## 🎉 Summary

This policy ensures that all Kubernetes Pods have mandatory labels (`environment`, `owner`, `project`, `team`) configured with non-empty values. The policy uses a fail-safe approach with `default result = "fail"` and validates both label presence and non-empty values using set comprehension, which provides a clean and maintainable validation pattern.
