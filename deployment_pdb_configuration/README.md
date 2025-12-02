# Deployment PDB Configuration Enforcement

This policy ensures that Kubernetes deployments with replicas <= 2 have PodDisruptionBudget configured.

## Policy Overview

**Rule**: Checks if deployments have PodDisruptionBudget configured with replicas <= 2

**Rationale**: Deployments with 2 or fewer replicas should have PDB to prevent disruption during maintenance or node drains.

## Policy Details

- **Default Result**: `fail`
- **Pass Condition**: 
  - Deployment has replicas > 2, OR
  - Deployment has replicas <= 2 AND PDB is configured (has `pdb-configured` annotation)

## Testing

Test manually:
```bash
opa eval --data policies/pdb-configuration-enforcement.rego \
        --input test-data/valid-deployment.json \
        "data.wiz.result"
```

## Notes

- The policy checks for the `pdb-configured` annotation to determine if PDB is configured.
- In a real environment, PDB existence would be checked by querying PDB resources separately.

