# Pod Probes Enforcement Policy

## 📋 Summary

**Policy Name**: Pod Probes Enforcement  
**Resource Type**: Pod  
**Enforcement**: Liveness and readiness probes must be configured for all containers  
**Status**: Completed  

## 🎯 Objective

Enforce that all Kubernetes Pod containers have both liveness and readiness probes configured to ensure healthy containers and proper traffic management.

## 📝 Description

This policy validates that all containers in Kubernetes Pods have both liveness and readiness probes specified. Probes ensure that unhealthy containers are restarted and that containers only receive traffic when they're ready.

## ✅ Policy Rules

- **Valid**: Pods where all containers have both liveness and readiness probes configured
- **Invalid**: Pods where any container is missing liveness or readiness probes
- **Skip**: Non-Pod resources (Deployments, Services, StatefulSets, etc.)

## 📁 Project Structure

```
pod_probes/
├── README.md                              # This file
├── Reference.md                           # Technical reference documentation
├── policies/                              # Policy files
│   └── probes-enforcement.rego           # Main Rego policy
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

# Navigate to pod_probes
cd pod_probes

# Test the policy
opa eval --data policies/probes-enforcement.rego \
        --input test-data/valid-pod-with-probes.json \
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

1. **Health Monitoring**: Ensure containers are properly monitored for health
2. **Traffic Management**: Prevent unhealthy containers from receiving traffic
3. **Automatic Recovery**: Enable automatic restart of unhealthy containers
4. **Production Stability**: Maintain stable and reliable services

## 📚 References

- [Kubernetes Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Liveness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
