package wiz

# This rule checks if deployments with replicas <= 1 have PDB configured
# Deployments with only 1 replica should not have PDB as it prevents disruption

default result = "fail"

# Check if deployment has replicas <= 1
hasLowReplicas if {
  input.spec.replicas <= 1
}

# Check if PDB exists (via annotation or assume it exists)
hasPDB if {
  input.metadata.annotations["pdb-exists"] == "true"
}

# Deny if replicas <= 1 AND PDB exists
result = "pass" if {
  not hasLowReplicas
}

result = "pass" if {
  hasLowReplicas
  not hasPDB
}

currentConfiguration := sprintf("Deployment has %d replicas but PDB exists or is being created", [input.spec.replicas])
expectedConfiguration := "Deployments with replicas <= 1 should not have PodDisruptionBudget configured"

