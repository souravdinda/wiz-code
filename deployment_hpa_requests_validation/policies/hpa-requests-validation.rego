package wiz

# This rule checks if workloads with HPA have CPU and memory requests configured
# HPA requires resource requests to function properly for scaling decisions

default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

# Check if HPA is configured (via annotation)
hasHPA if {
  input.metadata.annotations["hpa-enabled"] == "true"
}

# Check if all containers have CPU requests
allContainersHaveCPURequests if {
  count([c | c := input.spec.template.spec.containers[_]; not c.resources.requests.cpu]) == 0
  count([c | c := input.spec.template.spec.initContainers[_]; not c.resources.requests.cpu]) == 0
  count([c | c := input.spec.template.spec.ephemeralContainers[_]; not c.resources.requests.cpu]) == 0
  count(input.spec.template.spec.containers) > 0
}

# Check if all containers have memory requests
allContainersHaveMemoryRequests if {
  count([c | c := input.spec.template.spec.containers[_]; not c.resources.requests.memory]) == 0
  count([c | c := input.spec.template.spec.initContainers[_]; not c.resources.requests.memory]) == 0
  count([c | c := input.spec.template.spec.ephemeralContainers[_]; not c.resources.requests.memory]) == 0
  count(input.spec.template.spec.containers) > 0
}

# Pass if no HPA is configured
result = "pass" if {
  not hasHPA
}

# Pass if HPA is configured and all containers have requests
result = "pass" if {
  hasHPA
  allContainersHaveCPURequests
  allContainersHaveMemoryRequests
}

currentConfiguration := "Deployment has HPA configured but is missing CPU or memory requests"
expectedConfiguration := "Deployments with HPA should have CPU and memory requests configured for all containers"

