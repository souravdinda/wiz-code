package wiz

default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

result = "pass" {
  input.spec.template.spec[containerPaths[]][].livenessProbe
}

currentConfiguration := "DaemonSet containers do not have livenessProbe configured"
expectedConfiguration := "DaemonSet containers should have livenessProbe configured to ensure container health monitoring"
