package wiz

# This rule checks if Kubernetes deployments with replicas > 2 have PodTopologySpreadConstraints configured
# Workloads with multiple replicas should use topology spread constraints for better distribution

default result = "fail"

# Check if deployment has replicas > 2
hasHighReplicas if {
  input.spec.replicas > 2
}

# Check if deployment has PodTopologySpreadConstraints configured
hasTopologySpreadConstraints if {
  count(input.spec.template.spec.topologySpreadConstraints) > 0
}

result = "pass" if {
  not hasHighReplicas
}

result = "pass" if {
  hasHighReplicas
  hasTopologySpreadConstraints
}

currentConfiguration := sprintf("Deployment has %d replicas but PodTopologySpreadConstraints are not configured", [input.spec.replicas])
expectedConfiguration := "Deployments with more than 2 replicas should have PodTopologySpreadConstraints configured for better pod distribution"

