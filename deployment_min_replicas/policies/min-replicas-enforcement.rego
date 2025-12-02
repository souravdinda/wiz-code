package wiz

# This rule checks if Kubernetes deployments have at least 2 replicas for high availability
# Deployments with fewer than 2 replicas are not highly available

default result = "fail"

# Check if deployment has at least 2 replicas
hasMinimumReplicas if {
  input.spec.replicas >= 2
}

result = "pass" if {
  hasMinimumReplicas
}

currentConfiguration := sprintf("Deployment has %d replicas, which is less than the minimum of 2 for high availability", [input.spec.replicas])
expectedConfiguration := "Deployments should have at least 2 replicas configured for high availability"

