package wiz

# This rule checks if Pod containers have memory requests defined
# Memory requests help Kubernetes scheduler make better placement decisions
default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

# Check if all containers have memory requests defined
hasMemoryRequests {
    count({container | 
        container := input.object.spec[containerPaths[]][]
        container.resources.requests.memory
    }) == count({container | 
        container := input.object.spec[containerPaths[]][]
    })
}

result = "pass" {
    hasMemoryRequests
}

currentConfiguration := "One or more containers do not have memory requests defined"
expectedConfiguration := "All containers should have memory requests defined in resources.requests.memory"

