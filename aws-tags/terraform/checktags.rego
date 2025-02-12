# 	Use the Rego code below to programmatically define a IaC Configuration Rule. 
#	Import the IaC file you want to use as a reference, Wiz will parse the IaC 
#   file and output the parsed JSON format in the Test Data box.
#
#	Rule policy: 
#     Write in Rego the policy that if matched and returns True means
#     there is a security misconfiguration. It is helpful to be familiar with the
#     libraries available (https://docs.wiz.io/wiz-docs/docs/cloud-configuration-rules#cloud-configuration-rule-editor).
#
#	Result format:
#	  documentId id of the sample where the vulnerability occurs
#	  searchKey should indicate where the breaking point occurs in the sample
#	  keyExpectedValue should explain the expected value
#	  keyActualValue should explain the actual value detected

# This Rego policy checks for proper tag configuration in AWS resources
# It ensures resources have required tags and validates against default tags

package wiz

import data.generic.common as common_lib
import data.generic.terraform as terraLib

# Define mandatory tags that must be present in all AWS resources
mandatory_tags := {"car_id", "assignment_group", "applicationUid"}

# First rule: Checks if a resource is missing the entire 'tags' block
WizPolicy[result] {
	# Extract the resource from the input document
	resource := input.document[i].resource[res][name]
	terraLib.check_resource_tags(res)  # Ensure the resource is a valid target

	# Ensure default tags are not overriding the requirement
	check_default_tags == false

	# Check if the resource has a 'tags' block
	not common_lib.valid_key(resource, "tags")

	# Construct the result object indicating the missing 'tags' block
	result := {
		"documentId": input.document[i].id,
		"resourceName": terraLib.get_resource_name(resource, name),
		"searchKey": sprintf("%s[{{%s}}]", [res, name]),
		"issueType": "MissingAttribute",
		"keyExpectedValue": sprintf("%s[{{%s}}].tags should be defined and not null.", [res, name]),
		"keyActualValue": sprintf("Resource %s[{{%s}}].tags is undefined or null.", [res, name]),
		"resourceTags": object.get(resource, "tags", {}),
	}
}

# Second rule: Checks if required tags are missing within an existing 'tags' block
WizPolicy[result] {
	# Extract the resource from the input document
	resource := input.document[i].resource[res][name]
	terraLib.check_resource_tags(res)  # Ensure the resource is a valid target

	# Ensure default tags are not overriding the requirement
	check_default_tags == false

	# Identify missing required tags
	missing := missing_tags(resource.tags)
	missing_count := count(missing) > 0  # Determine if any tags are missing

	missing_count  # Ensure the rule evaluates to true if tags are missing

	# Construct the result object indicating the missing required tags
	result := {
		"documentId": input.document[i].id,
		"resourceName": terraLib.get_resource_name(resource, name),
		"searchKey": sprintf("%s[{{%s}}].tags", [res, name]),
		"issueType": "MissingAttribute",
		"keyExpectedValue": sprintf("%s[{{%s}}].tags has required tags defined.", [res, name]),
		"keyActualValue": sprintf("Resource %s[{{%s}}].tags is missing required tags: %v.\n\tResource has Resource Tags: %v", [res, name, missing, object.get(resource, "tags", {})]),
		"resourceTags": object.get(resource, "tags", {}),
	}
}

# Helper function: Returns a set of missing required tags for a given resource
missing_tags(tags) := {tag | mandatory_tags[tag]; not tags[tag]}

# Helper function: Checks if default tags are configured in the AWS provider
# Returns true if default tags are found in either provider format
check_default_tags {
	# Check first provider format for default tags
	common_lib.valid_key(input.document[_].provider["aws"].default_tags, "tags")
} else {
	# Check alternate provider format for default tags
	common_lib.valid_key(input.document[_].provider["aws"][_].default_tags, "tags")
} else = false {
	# Return false if no default tags are found, ensuring policy enforcement
	true
}
