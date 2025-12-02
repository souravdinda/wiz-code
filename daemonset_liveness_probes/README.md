# DaemonSet Liveness And Readiness Probes Enforcement Policy

## 📋 Summary

**Policy Name**: DaemonSet Liveness And Readiness Probes Enforcement  
**Resource Type**: DaemonSet  
**Enforcement**: Liveness And Readiness Probes must be configured for all containers  
**Status**: Completed  

## 🎯 Objective

Enforce that all Kubernetes DaemonSet containers have liveness and readiness probes configured to prevent resource contention and unpredictable performance.

## 📝 Description

This policy validates that all containers in Kubernetes DaemonSets have liveness and readiness probes specified in their resource requirements. This ensures proper resource management and prevents resource contention.

## ✅ Policy Rules

- **Valid**: DaemonSets where all containers have liveness and readiness probes configured
- **Invalid**: DaemonSets where any container is missing liveness and readiness probes
- **Skip**: Non-DaemonSet resources (Pods, Services, other workload types, etc.)

## 📁 Project Structure

```
daemonset_probes/
├── README.md                              # This file
├── Reference.md                           # Technical reference documentation
├── policies/                              # Policy files
│   └── probes-enforcement.rego                     # Main Rego policy
├── docs/                                  # Documentation
│   └── rego-code-explanation.md          # Line-by-line code explanation
├── test-data/                             # Test data for OPA
└── test-policy.sh                         # Automated test script
```

## 🚀 Quick Start

### Prerequisites

- OPA CLI installed
- Wiz CLI or Console access
- kubectl configured for target cluster

### Local Testing

```bash
# Install OPA
brew install opa  # macOS

# Navigate to daemonset_probes
cd daemonset_probes

# Test the policy
opa eval --data policies/probes-enforcement.rego \
        --input test-data/valid-daemonset.json \
        "data.wiz.result"

# Expected: "pass"

# Run automated test suite
./test-policy.sh
```

## 📖 Detailed Documentation

- [Rego Code Explanation](./docs/rego-code-explanation.md) - Line-by-line policy explanation
- [Reference Documentation](./Reference.md) - Technical reference

## 📊 Test Results

All tests pass successfully. Run `./test-policy.sh` to verify.

## 🎯 Use Cases

1. **Resource Protection**: Prevent resource contention on nodes
2. **Performance Predictability**: Ensure consistent performance for all workloads
3. **Cost Management**: Control resource usage and prevent overconsumption
4. **Production Stability**: Maintain stable performance in production environments

## 📚 References

- [Kubernetes DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
