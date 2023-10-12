#!/bin/sh
[ ! -d ".tflint.d" ] && tflint --init
tflint
[ $? -eq 0 ]  || exit $? # Pass the exit code from tflint
tflint --config ../../.tflint.hcl --chdir ./modules/simphera_aws_instance
[ $? -eq 0 ]  || exit $? # Pass the exit code from tflint


