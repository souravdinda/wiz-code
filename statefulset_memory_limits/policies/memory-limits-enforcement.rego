package wiz

# This rule checks if StatefulSet containers have memory limits defined
# Memory limits help prevent resource contention and unpredictable performance
default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

# Check if all containers have memory limits defined
hasMemoryLimits {
    count({container | 
        container := input.object.spec.template.spec[containerPaths[]][]
        container.resources.limits.memory
    }) == count({container | 
        container := input.object.spec.template.spec[containerPaths[]][]
    })
}

result = "pass" {
    hasMemoryLimits
}

currentConfiguration := "One or more containers do not have memory limits defined"
expectedConfiguration := "All containers should have memory limits defined in resources.limits.memory"
