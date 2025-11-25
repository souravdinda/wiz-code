package wiz

# Invesco-Memory Requests Not Set
# This rule checks if Kubernetes deployments have memory requests configured for all containers
# Deployments without memory requests can lead to resource contention and unpredictable performance
default result = "pass"

currentConfiguration := sprintf("Deployment '%s' containers without memory requests: %v", [input.metadata.name, containers_without_memory_requests])
expectedConfiguration := "All containers should have memory requests specified in their resource requirements"

# Get containers that don't have memory requests set
containers_without_memory_requests := [container.name | 
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.memory
]

result = "fail" if {
    count(containers_without_memory_requests) > 0
}

result = "skip" if {
    input.kind != "Deployment"
}
