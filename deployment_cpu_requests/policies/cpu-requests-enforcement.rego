package wiz

# Invesco-CPU Requests Not Set
# This rule checks if Kubernetes deployments have CPU requests configured for all containers
# Deployments without CPU requests can lead to resource contention and unpredictable performance
default result = "pass"

currentConfiguration := sprintf("Deployment '%s' containers without CPU requests: %v", [input.metadata.name, containers_without_cpu_requests])
expectedConfiguration := "All containers should have CPU requests specified in their resource requirements"

# Get containers that don't have CPU requests set
containers_without_cpu_requests := [container.name | 
    container := input.spec.template.spec.containers[_]
    not container.resources.requests.cpu
]

result = "fail" if {
    count(containers_without_cpu_requests) > 0
}

result = "skip" if {
    input.kind != "Deployment"
}
