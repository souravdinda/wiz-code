package wiz

# Invesco-Mandatory Tags Not Set
# This rule checks if Kubernetes pods have mandatory tags/labels configured
# Pods without mandatory tags make it difficult to track ownership, environment, and resource management
default result = "pass"

currentConfiguration := sprintf("Pod '%s' missing mandatory tags: %v", [input.metadata.name, missing_tags])
expectedConfiguration := "All pods should have mandatory tags specified: env, owner, name"

# Define mandatory tags
mandatory_tags := {"env", "owner", "name"}

# Get current tags from labels
current_tags := {tag_name | some tag_name; tag_value := input.metadata.labels[tag_name]}

# Find missing tags by checking which mandatory tags are NOT in current tags
missing_tags := [tag | mandatory_tags[tag]; not current_tags[tag]]

result = "skip" if {
    input.kind != "Pod"
}

result = "fail" if {
    input.kind == "Pod"
    count(missing_tags) > 0
}

