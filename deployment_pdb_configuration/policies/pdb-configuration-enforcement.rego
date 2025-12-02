package wiz

# This rule checks if Kubernetes deployments with replicas <= 2 have PodDisruptionBudget configured
# Deployments with 2 or fewer replicas should have PDB to prevent disruption

default result = "fail"

# Check if deployment has replicas <= 2
hasLowReplicas if {
  input.spec.replicas <= 2
}

# Check if PDB is configured (via annotation)
hasPDB if {
  input.metadata.annotations["pdb-configured"] == "true"
}

result = "pass" if {
  not hasLowReplicas
}

result = "pass" if {
  hasLowReplicas
  hasPDB
}

currentConfiguration := sprintf("Deployment has %d replicas but PodDisruptionBudget is not configured", [input.spec.replicas])
expectedConfiguration := "Deployments with replicas <= 2 should have PodDisruptionBudget configured to prevent disruption"

