# DaemonSet Readiness Probes Enforcement Policy

## 📋 Summary

**Policy Name**: DaemonSet Readiness Probes Enforcement  
**Resource Type**: DaemonSet  
**Enforcement**: Readiness Probes must be configured for all containers  
**Status**: Completed  

## 🎯 Objective

Enforce that all Kubernetes DaemonSet containers have readiness probes configured to ensure containers are ready to serve traffic before receiving requests.

## 📝 Description

This policy validates that all containers in Kubernetes DaemonSets have readiness probes specified. Readiness probes determine if a container is ready to accept traffic. This ensures proper traffic routing and prevents sending requests to containers that are not yet ready.

## ✅ Policy Rules

- **Valid**: DaemonSets where all containers have readiness probes configured
- **Invalid**: DaemonSets where any container is missing readiness probes
- **Skip**: Non-DaemonSet resources (Pods, Services, other workload types, etc.)

## 📁 Project Structure

```
daemonset_readiness_probes/
├── README.md                              # This file
├── policies/                              # Policy files
│   └── readiness-probe-enforcement.rego  # Main Rego policy
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

# Navigate to daemonset_readiness_probes
cd daemonset_readiness_probes

# Test the policy
opa eval --data policies/readiness-probe-enforcement.rego \
        --input test-data/valid-daemonset-with-readiness.json \
        "data.wiz.result"

# Expected: "pass"

# Run automated test suite
./test-policy.sh
```

## 📊 Test Results

All tests pass successfully. Run `./test-policy.sh` to verify.

## 🎯 Use Cases

1. **Traffic Routing**: Ensure only ready containers receive traffic
2. **Service Availability**: Prevent sending requests to containers that are not ready
3. **Production Stability**: Maintain stable service availability in production environments
4. **Health Monitoring**: Enable proper health checks for container readiness

## 📚 References

- [Kubernetes DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
- [Readiness Probes](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes)

