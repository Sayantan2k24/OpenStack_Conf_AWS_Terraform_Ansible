#!/bin/bash

terraform init

terraform fmt

terraform validate

terraform plan

# Prompt the user to proceed
read -p "Please review the plan. Press enter to continue or CTRL+C to cancel." continue_confirmation

# Define a function to check for errors and rerun terraform apply if needed
run_apply() {
    terraform apply --auto-approve
    if [ $? -ne 0 ]; then
        echo "Error occurred during apply. Retrying..."
        run_apply
    fi
}


# Run terraform apply with error handling
run_apply

