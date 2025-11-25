package wiz

# Invesco-Memory Limits Not Set
# This rule checks if Kubernetes deployments have memory limits configured for all containers
# Deployments without memory limits can lead to resource contention and unpredictable performance
default result = "pass"

currentConfiguration := sprintf("Deployment '%s' containers without memory limits: %v", [input.metadata.name, containers_without_memory_limits])
expectedConfiguration := "All containers should have memory limits specified in their resource requirements"

# Get containers that don't have memory limits set
containers_without_memory_limits := [container.name | 
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.memory
]

result = "fail" if {
    count(containers_without_memory_limits) > 0
}

result = "skip" if {
    input.kind != "Deployment"
}
