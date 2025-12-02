# Deployment HPA Requests Validation

This policy ensures that Kubernetes Deployments with HPA (Horizontal Pod Autoscaler) have CPU and memory requests configured for all containers.

## Policy Overview

**Rule**: Denies workloads with HPA but missing CPU/memory requests

**Rationale**: HPA requires resource requests to function properly for scaling decisions. Without requests, HPA cannot determine when to scale based on resource utilization.

## Policy Details

- **Default Result**: `fail`
- **Pass Condition**: 
  - Deployment does not have HPA configured (no `hpa-enabled` annotation), OR
  - Deployment has HPA AND all containers have both CPU and memory requests configured

## Testing

Run the test script:
```bash
./test-policy.sh
```

Or test manually:
```bash
opa eval --data policies/hpa-requests-validation.rego \
        --input test-data/valid-deployment-with-requests.json \
        "data.wiz.result"
```

## Test Cases

1. **Valid**: Deployment with HPA annotation and all containers have CPU/memory requests
2. **Invalid**: Deployment with HPA annotation but missing CPU or memory requests
3. **Valid**: Deployment without HPA annotation (policy doesn't apply)

