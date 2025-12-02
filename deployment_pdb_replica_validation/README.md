# Deployment PDB Replica Validation

This policy ensures that deployments with replicas <= 1 do not have PodDisruptionBudget (PDB) configured.

## Policy Overview

**Rule**: Denies deployments with replicas <= 1 when PDB exists or is being created

**Rationale**: Deployments with only 1 replica should not have PDB as it prevents disruption. PDB requires at least 2 replicas to allow for pod disruption while maintaining availability.

## Policy Details

- **Default Result**: `fail`
- **Pass Condition**: 
  - Deployment has replicas > 1, OR
  - Deployment has replicas <= 1 AND no PDB exists (no `pdb-exists` annotation)

## Testing

Test manually:
```bash
opa eval --data policies/pdb-replica-validation.rego \
        --input test-data/valid-deployment.json \
        "data.wiz.result"
```

## Notes

- The policy checks for the `pdb-exists` annotation to determine if PDB is configured.
- In a real environment, PDB existence would be checked by querying PDB resources separately.

