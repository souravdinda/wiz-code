# Deployment Minimum Replicas Enforcement

This policy ensures that Kubernetes Deployments have at least 2 replicas configured for high availability.

## Policy Overview

**Rule**: All deployments should have at least 2 replicas for high availability

**Rationale**: Deployments with fewer than 2 replicas are not highly available. If a single pod fails, the service becomes unavailable.

## Policy Details

- **Default Result**: `fail`
- **Pass Condition**: Deployment has `spec.replicas >= 2`

## Testing

Run the test script:
```bash
./test-policy.sh
```

Or test manually:
```bash
opa eval --data policies/min-replicas-enforcement.rego \
        --input test-data/valid-deployment.json \
        "data.wiz.result"
```

## Test Cases

1. **Valid**: Deployment with 2 or more replicas
2. **Invalid**: Deployment with 1 replica

