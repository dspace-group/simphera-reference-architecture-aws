#!/bin/sh
[ ! -d "~/.tflint.d/plugins" ] && tflint --init
tflint
tflint --config ../../.tflint.hcl --chdir ./modules/simphera_aws_instance
