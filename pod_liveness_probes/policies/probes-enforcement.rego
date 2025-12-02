package wiz

default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

result = "pass" {
  input.spec[containerPaths[]][].livenessProbe
}

currentConfiguration := "Pod containers do not have livenessProbe configured"
expectedConfiguration := "Pod containers should have livenessProbe configured to ensure container health monitoring"

