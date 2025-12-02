package wiz

# Check if Deployment has custom readiness probes defined for containers

default result = "fail"

# Check if any container has a readiness probe defined

hasReadinessProbe {
    input.object.spec.template.spec.containers[_].readinessProbe
}

# Check if any init container has a readiness probe defined

hasInitContainerReadinessProbe {
    input.object.spec.template.spec.initContainers[_].readinessProbe
}

# Check if any ephemeral container has a readiness probe defined

hasEphemeralContainerReadinessProbe {
    input.object.spec.template.spec.ephemeralContainers[_].readinessProbe
}

result = "pass" {
    hasReadinessProbe
} else = "pass" {
    hasInitContainerReadinessProbe
} else = "pass" {
    hasEphemeralContainerReadinessProbe
}

currentConfiguration := "Deployment containers do not have readiness probes configured"
expectedConfiguration := "Deployment containers should have readiness probes configured to ensure proper health checking"

