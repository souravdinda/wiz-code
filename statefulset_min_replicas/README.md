# StatefulSet Minimum Replicas Enforcement

This policy ensures that Kubernetes StatefulSets have at least 2 replicas configured for high availability.

## Policy Overview

**Rule**: All statefulsets should have at least 2 replicas for high availability

**Rationale**: StatefulSets with fewer than 2 replicas are not highly available. If a single pod fails, the service becomes unavailable.

## Policy Details

- **Default Result**: `fail`
- **Pass Condition**: StatefulSet has `spec.replicas >= 2`

## Testing

Test manually:
```bash
opa eval --data policies/min-replicas-enforcement.rego \
        --input test-data/valid-statefulset.json \
        "data.wiz.result"
```

## Test Cases

1. **Valid**: StatefulSet with 2 or more replicas
2. **Invalid**: StatefulSet with 1 replica

