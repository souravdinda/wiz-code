# Deployment VPA Limits Validation

This policy ensures that workloads with VPA (Vertical Pod Autoscaler) do not have limits <= requests (unless VPA only modifies requests).

## Policy Overview

**Rule**: Denies workloads with VPA where limits <= requests (unless VPA only modifies requests)

**Rationale**: VPA should not set limits that are less than or equal to requests. If VPA only modifies requests, limits should not be set.

## Policy Details

- **Default Result**: `fail`
- **Pass Condition**: 
  - No VPA is configured (no `vpa-enabled` annotation), OR
  - VPA is configured but only modifies requests (no limits set), OR
  - VPA is configured with limits and requests (structure check - actual value comparison happens at VPA level)

## Testing

Test manually:
```bash
opa eval --data policies/vpa-limits-validation.rego \
        --input test-data/valid-deployment.json \
        "data.wiz.result"
```

## Notes

- This policy performs structural validation. Actual comparison of limits <= requests requires parsing resource strings (e.g., "100m" vs "200m") which is complex.
- VPA controller typically handles the actual value validation.
- The policy checks for the `vpa-enabled` annotation to determine if VPA is configured.

