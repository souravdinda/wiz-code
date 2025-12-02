package wiz

# This Cloud Configuration Rule checks if Kubernetes statefulsets have mandatory tags/labels configured

default result = "fail"

mandatoryLabels := {"environment", "owner", "project", "team"}

# Check if all mandatory labels are present
allMandatoryLabelsPresent {
  count({label | mandatoryLabels[label]; input.metadata.labels[label]}) == count(mandatoryLabels)
}

# Check if all mandatory labels have non-empty values
allMandatoryLabelsHaveValues {
  count({label | mandatoryLabels[label]; input.metadata.labels[label] != ""}) == count(mandatoryLabels)
}

result = "pass" {
  allMandatoryLabelsPresent
  allMandatoryLabelsHaveValues
}

currentConfiguration := sprintf("StatefulSet is missing mandatory labels or has empty values. Present labels: %v", [input.metadata.labels])
expectedConfiguration := sprintf("StatefulSet should have all mandatory labels with non-empty values: %v", [mandatoryLabels])
