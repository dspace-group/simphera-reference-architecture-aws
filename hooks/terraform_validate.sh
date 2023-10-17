#!/bin/sh
#[ ! -d ".terraform" ] && terraform init || echo "skipping terraform init"
terraform init
terraform validate
