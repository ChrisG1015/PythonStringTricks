#!/bin/bash

role_name=$1

# Step 1: Get the policy name attached to the IAM role
policy_name=$(aws iam get-role --role-name $role_name --query "Role.RoleName" --output text)

# Step 2: Get the list of attached policies to the IAM role
attached_policies=$(aws iam list-attached-role-policies --role-name $role_name --query "AttachedPolicies[].PolicyArn" --output json)

# Step 3: Detach each policy from the IAM role
for policy_arn in $(echo $attached_policies | jq -r '.[]'); do
    echo "Detaching policy: $policy_arn from role: $role_name"
    aws iam detach-role-policy --role-name $role_name --policy-arn $policy_arn
done

# Step 4: Delete the IAM role
echo "Deleting IAM role: $role_name"
aws iam delete-role --role-name $role_name

echo "IAM role $role_name deleted successfully."
