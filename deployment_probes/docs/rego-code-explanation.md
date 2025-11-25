# Rego Policy Code Explanation - Line by Line

This document provides a detailed line-by-line explanation of the Deployment Liveness And Readiness Probes Enforcement Rego policy.

## 📋 Policy Overview

The policy validates that all Kubernetes Deployment containers have liveness and readiness probes configured.

## 🔍 Complete Policy Code

See `policies/probes-enforcement.rego` for the complete policy code.

## 📝 Key Components

### Package Declaration
```rego
package wiz
```
**What it does:** Declares the package name for the policy.

### Default Result
```rego
default result = "pass"
```
**What it does:** Sets the default result to "pass", meaning the policy passes unless a failure condition is met.

### Container Validation
The policy checks all containers in the Deployment template to ensure liveness and readiness probes are configured.

### Result Rules
- `result = "fail"` if containers are missing liveness and readiness probes
- `result = "skip"` if the resource is not a Deployment

## 🎯 Summary

This policy ensures all Deployment containers have liveness and readiness probes configured, preventing resource contention and ensuring predictable performance.
