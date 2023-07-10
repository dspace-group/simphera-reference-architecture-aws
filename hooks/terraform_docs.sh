#!/bin/sh
terraform-docs markdown table --output-file README.md --output-mode inject . 
terraform-docs tfvars hcl . > terraform.tfvars.example