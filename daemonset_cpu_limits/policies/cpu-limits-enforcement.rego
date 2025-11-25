package wiz

# Invesco-CPU Limits Not Set
# This rule checks if Kubernetes daemonsets have CPU limits configured for all containers
# DaemonSets without CPU limits can lead to resource contention and unpredictable performance
default result = "pass"

currentConfiguration := sprintf("DaemonSet '%s' containers without CPU limits: %v", [input.metadata.name, containers_without_cpu_limits])
expectedConfiguration := "All containers should have CPU limits specified in their resource requirements"

# Get containers that don't have CPU limits set
containers_without_cpu_limits := [container.name | 
    container := input.spec.template.spec.containers[_]
    not container.resources.limits.cpu
]

result = "fail" if {
    count(containers_without_cpu_limits) > 0
}

result = "skip" if {
    input.kind != "DaemonSet"
}
