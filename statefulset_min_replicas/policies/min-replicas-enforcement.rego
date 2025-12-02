package wiz

# This rule checks if Kubernetes statefulsets have at least 2 replicas for high availability
# StatefulSets with fewer than 2 replicas are not highly available

default result = "fail"

# Check if statefulset has at least 2 replicas
hasMinimumReplicas if {
  input.spec.replicas >= 2
}

result = "pass" if {
  hasMinimumReplicas
}

currentConfiguration := sprintf("StatefulSet has %d replicas, which is less than the minimum of 2 for high availability", [input.spec.replicas])
expectedConfiguration := "StatefulSets should have at least 2 replicas configured for high availability"

