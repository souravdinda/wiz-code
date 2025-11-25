package wiz

# Invesco-Liveness and Readiness Probes Not Set
# This rule checks if Kubernetes pods have both liveness and readiness probes configured for all containers
# Pods without probes can lead to unhealthy containers serving traffic or containers not being restarted when needed
default result = "pass"

currentConfiguration := sprintf("Pod '%s' containers without liveness or readiness probes: %v", [input.metadata.name, containers_without_probes])
expectedConfiguration := "All containers should have both liveness and readiness probes specified"

# Get containers that don't have both liveness and readiness probes set
# Check each container - if it's missing liveness OR missing readiness, include it
containers_without_probes := [container.name | 
    container := input.spec.containers[_]
    not has_both_probes(container)
]

# Helper function to check if container has both probes
has_both_probes(container) if {
    container.livenessProbe
    container.readinessProbe
}

result = "fail" if {
    count(containers_without_probes) > 0
}

result = "skip" if {
    input.kind != "Pod"
}

