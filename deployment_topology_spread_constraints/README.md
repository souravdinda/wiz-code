# Deployment Topology Spread Constraints Enforcement

This policy ensures that Kubernetes Deployments with more than 2 replicas have PodTopologySpreadConstraints configured for better pod distribution across nodes.

## Policy Overview

**Rule**: Denies workloads with replicas > 2 but missing PodTopologySpreadConstraints

**Rationale**: Workloads with multiple replicas should use topology spread constraints to ensure pods are distributed across different nodes, zones, or other topology domains for better availability and resource utilization.

## Policy Details

- **Default Result**: `fail`
- **Pass Condition**: 
  - Deployment has replicas <= 2, OR
  - Deployment has replicas > 2 AND has PodTopologySpreadConstraints configured

## Testing

Run the test script:
```bash
./test-policy.sh
```

Or test manually:
```bash
opa eval --data policies/topology-spread-constraints-enforcement.rego \
        --input test-data/valid-deployment-with-constraints.json \
        "data.wiz.result"
```

## Test Cases

1. **Valid**: Deployment with 3 replicas and topology spread constraints configured
2. **Valid**: Deployment with 2 or fewer replicas (no constraints required)
3. **Invalid**: Deployment with 5 replicas but no topology spread constraints

