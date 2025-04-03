#!/bin/sh
terraform-docs markdown table --output-file README.md --output-mode inject .
terraform-docs -c tfvars.hcl.terraform-docs.yml .
terraform-docs tfvars json .
