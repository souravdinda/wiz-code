# Pod Mandatory Tags Enforcement Policy

## 📋 Summary

**Policy Name**: Pod Mandatory Tags Enforcement  
**Resource Type**: Pod  
**Enforcement**: Mandatory tags (env, owner, name) must be configured  
**Status**: Completed  

## 🎯 Objective

Enforce that all Kubernetes Pods have mandatory tags/labels configured to enable proper tracking of ownership, environment, and resource management.

## 📝 Description

This policy validates that all Kubernetes Pods have mandatory tags (env, owner, name) specified in their labels. These tags are essential for tracking resource ownership, environment classification, and resource management.

## ✅ Policy Rules

- **Valid**: Pods where all mandatory tags (env, owner, name) are present
- **Invalid**: Pods where any mandatory tag is missing
- **Skip**: Non-Pod resources (Deployments, Services, StatefulSets, etc.)

## 📁 Project Structure

```
pod_mandatory_tags/
├── README.md                              # This file
├── Reference.md                           # Technical reference documentation
├── policies/                              # Policy files
│   └── mandatory-tags-enforcement.rego   # Main Rego policy
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

# Navigate to pod_mandatory_tags
cd pod_mandatory_tags

# Test the policy
opa eval --data policies/mandatory-tags-enforcement.rego \
        --input test-data/valid-pod-with-tags.json \
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

1. **Resource Tracking**: Enable proper tracking of resource ownership
2. **Environment Management**: Classify resources by environment
3. **Cost Management**: Track resource costs by owner and environment
4. **Compliance**: Meet organizational tagging requirements

## 📚 References

- [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)
