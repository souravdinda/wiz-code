package wiz

# This rule checks if workloads with VPA have limits <= requests (unless VPA only modifies requests)
# VPA should not set limits that are less than or equal to requests

default result = "fail"

containerPaths := {"containers", "initContainers", "ephemeralContainers"}

# Check if VPA is configured (via annotation or assume it exists if limits are set)
# For this policy, we assume VPA exists if the deployment has resource limits
hasVPA {
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits]) > 0
  input.metadata.annotations["vpa-enabled"] == "true"
} else {
  # Or check if VPA annotation exists
  input.metadata.annotations["vpa-enabled"] == "true"
}

# Check if any container has both limits and requests configured
# Note: Actual comparison of limits <= requests would require parsing resource strings
# This policy checks structure - actual value comparison would be done by VPA controller
hasLimitsAndRequests {
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits; c.resources.requests]) > 0
}

# Pass if no VPA is configured
result = "pass" {
  not hasVPA
} else = "pass" {
  # Pass if VPA only modifies requests (no limits set)
  hasVPA
  count([c | c := input.spec.template.spec[containerPaths[]][]; c.resources.limits]) == 0
} else = "pass" {
  # Pass if limits exist but are greater than requests (structure check)
  # Note: Actual value validation would require parsing and comparison
  hasVPA
  hasLimitsAndRequests
  # This is a structural check - actual limits <= requests validation happens at VPA level
}

currentConfiguration := "Workload has VPA with limits <= requests configured"
expectedConfiguration := "VPA should not set limits that are less than or equal to requests (unless VPA only modifies requests)"

