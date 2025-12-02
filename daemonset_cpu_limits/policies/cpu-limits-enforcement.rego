package wiz

# This rule checks if Kubernetes pods have CPU limits configured for all containers
# Pods without CPU limits can lead to resource contention and unpredictable performance
default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

result = "pass" {
  input.spec.template.spec[containerPaths[]][].resources.limits.cpu
}

currentConfiguration := "CPU limits are not set for containers in the daemonset"
expectedConfiguration := "CPU limits should be set for all containers in the daemonset"
