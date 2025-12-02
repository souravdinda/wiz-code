package wiz

# This rule checks if Kubernetes pods have CPU requests configured for all containers
# Pods without CPU requests can lead to resource contention and unpredictable performance
default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

result = "pass" {
  input.spec[containerPaths[]][].resources.requests.cpu
}

currentConfiguration := "CPU requests are not set for containers in the pod"
expectedConfiguration := "CPU requests should be set for all containers in the pod"

