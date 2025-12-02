package wiz

default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

result = "pass" {
  input.spec.template.spec[containerPaths[]][].livenessProbe
}

currentConfiguration := "Deployment containers do not have livenessProbe configured"
expectedConfiguration := "Deployment containers should have livenessProbe configured to ensure container health monitoring"
