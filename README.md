Automate Openstack Cloud Setup On CentOS 8 Using Terraform and Ansible
======================================================================

# Guide

## Prerequistes 1 -> Terraform and Ansible is preinstalled and configured in your setup
## Prerequisties 2 ->  AWS IAM user is configured with the secret key in Your AWS account

# Login to root user in your system
sudo su -

## Clone the repo
git clone https://github.com/Sayantan2k24/OpenStack_Conf_AWS_Terraform_Ansible.git

## Go inside the Workspace
cd OpenStack_Conf_AWS_Terraform_Ansible/

## Go inside the workspace of terraform 
cd terraform_aws_ec2

## Create Private and Public key
ssh-keygen -t rsa

# Change the permission# 
chmod 600 "private key"


# Define the Private key in variables.tf file

## Create the terraform.tfvars file
## Check the Documentation
https://registry.terraform.io/providers/hashicorp/aws/latest/docs


## Now run the Script
./control-script.sh





