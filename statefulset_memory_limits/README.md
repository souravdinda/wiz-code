# StatefulSet Memory Limits Enforcement Policy

## 📋 Summary

**Policy Name**: StatefulSet Memory Limits Enforcement  
**Resource Type**: StatefulSet  
**Enforcement**: Memory Limits must be configured for all containers  
**Status**: Completed  

## 🎯 Objective

Enforce that all Kubernetes StatefulSet containers have memory limits configured to prevent resource contention and unpredictable performance.

## 📝 Description

This policy validates that all containers in Kubernetes StatefulSets have memory limits specified in their resource requirements. This ensures proper resource management and prevents resource contention.

## ✅ Policy Rules

- **Valid**: StatefulSets where all containers have memory limits configured
- **Invalid**: StatefulSets where any container is missing memory limits
- **Skip**: Non-StatefulSet resources (Pods, Services, other workload types, etc.)

## 📁 Project Structure

```
statefulset_memory_limits/
├── README.md                              # This file
├── Reference.md                           # Technical reference documentation
├── policies/                              # Policy files
│   └── memory-limits-enforcement.rego                     # Main Rego policy
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

# Navigate to statefulset_memory_limits
cd statefulset_memory_limits

# Test the policy
opa eval --data policies/memory-limits-enforcement.rego \
        --input test-data/valid-statefulset.json \
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

- [Kubernetes StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
