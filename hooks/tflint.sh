#!/bin/sh
tflint --init
tflint
tflint --config ../../.tflint.hcl --chdir ./modules/simphera_aws_instance
