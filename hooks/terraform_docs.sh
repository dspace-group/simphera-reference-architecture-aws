#!/bin/sh
terraform-docs markdown table --output-file README.md --output-mode inject . 
terraform-docs tfvars hcl --description . > terraform.tfvars.example
terraform-docs tfvars json . > terraform.json.example