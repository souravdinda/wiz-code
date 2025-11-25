# DaemonSet Cpu Requests Enforcement Policy

## 📋 Summary

**Policy Name**: DaemonSet Cpu Requests Enforcement  
**Resource Type**: DaemonSet  
**Enforcement**: Cpu Requests must be configured for all containers  
**Status**: Completed  

## 🎯 Objective

Enforce that all Kubernetes DaemonSet containers have CPU requests configured to prevent resource contention and unpredictable performance.

## 📝 Description

This policy validates that all containers in Kubernetes DaemonSets have CPU requests specified in their resource requirements. This ensures proper resource management and prevents resource contention.

## ✅ Policy Rules

- **Valid**: DaemonSets where all containers have CPU requests configured
- **Invalid**: DaemonSets where any container is missing CPU requests
- **Skip**: Non-DaemonSet resources (Pods, Services, other workload types, etc.)

## 📁 Project Structure

```
daemonset_cpu_requests/
├── README.md                              # This file
├── Reference.md                           # Technical reference documentation
├── policies/                              # Policy files
│   └── cpu-requests-enforcement.rego                     # Main Rego policy
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

# Navigate to daemonset_cpu_requests
cd daemonset_cpu_requests

# Test the policy
opa eval --data policies/cpu-requests-enforcement.rego \
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
